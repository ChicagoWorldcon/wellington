require "people"

class Import::ChicagoBidMembers

  # import a chicago bid member dump. All we're doing here is creating new users if needed, and then creating a paid
  # reservation for them.

  attr_reader :voters, :people, :payments, :description, :errors

  def initialize(voter_csv, people_csv, payments_csv, description)
    @description = description
    @errors = []
    # add a synthetic member number / key
    voter_csv.each_with_index { |v, i| v[:conzealand_membership_number] = i }
    @voters = voter_csv
    @people = people_csv  # must have headers
    @payments = payments_csv # must have headers
  end

  def call
    Claim.transaction do
      parse_all_imports
    end
  end

  def parse_all_imports
    np = People::NameParser.new

    # reservations we created in voting; easier to find them later
    remembered_reservations = Hash.new

    voters.each do |row|
      next unless row[:email].present?
      email = row[:email].downcase.strip

      # First, they get a supporting membership
      user = User.find_or_create_by!(email: email)
      reservation = ClaimMembership.new(voter_membership, customer: user).call
      reservation.update!(state: Reservation::PAID)

      # We'll create a VERY sparse contact for them
      name = np.parse(row[:name])
      if name[:parsed]
        first_name = name[:first]
        last_name = name[:last]
      else
        first_name = row[:name]
        last_name = ""
      end

      pubs_format = if row[:paper_publications].present? && row[:paper_publications].downcase.strip == "y"
                      ChicagoContact::PAPERPUBS_BOTH
                    else
                      ChicagoContact::PAPERPUBS_ELECTRONIC
                    end

      publish_name = if row[:publish_name].present? && row[:publish_name].downcase.strip == "n"
                       false
                     else
                       true
                     end

      contact = ChicagoContact.new(
        claim: reservation.active_claim,
        first_name: first_name,
        last_name: last_name,
        badge_title: row[:badge_name],
        show_in_listings: publish_name,
        address_line_1: row[:purchaser_address],
        city: row[:purchaser_city],
        province: row[:purchaser_state],
        postal: row[:purchaser_postal],
        country: row[:purchaser_country],
        publication_format: pubs_format,
        email: user.email,
      )
      contact.as_import.save!
      user.notes.create!(content: "Voter import from CoNZealand member ##{row[:conzealand_membership_number]}")
      user.notes.create!(content: "#{description}")

      # Let's remember this reservation for later; we'll store it by CoNZ member number
      remembered_reservations[row[:conzealand_membership_number]] = reservation

      charge = Charge.cash.successful.create!(
        user: user,
        reservation: reservation,
        amount: voter_membership.price,
        comment: "Voter fee for CoNZealand member ##{row[:conzealand_membership_number]}"
      )
      charge.save!
    end

    p "Imported #{User.count} users, #{remembered_reservations.size} reservations total"

    people.each do |row|
      next unless ["BidFriend", "BidStar", "BidCommittee"].include? row[:membership]

      email = row[:email].downcase.strip

      voter_entries = voters_by_email[email]
      # We have these conditions:
      # 1. the voter is present and we have an exact match for the name in either the legal name or the first + last
      #    -- upgrade them to attending
      # 2. the voter is present, but we can't match the name to any voter name exactly
      #    -- we create a supporting membership for the user
      #    -- member services can sort it out
      #    -- we keep this email in a list to print after
      # 2b. the friend matches more than one voter
      #    -- we upgrade the first voter matched
      # 3. the voter is not present
      #    -- we create a supporting membership and note that they were a friend of the bid but didn't vote
      if voter_entries.present?
        bid_supporter_names = Set.new(name_options(row[:legal_name]).map(&:downcase)).add("#{row[:public_first_name]} #{row[:public_first_name]}".downcase)
        matched_voters = voter_entries.select do |voter_entry|
          voter_names = Set.new(name_options(voter_entry[:name]))
          voter_names & bid_supporter_names
        end

        if matched_voters.present? && matched_voters.size == 1
          matched_voter = matched_voters.each.next[:conzealand_membership_number]
          reservation_to_upgrade = remembered_reservations[matched_voter]
          user = reservation_to_upgrade.user

          user.notes.create!(content: "#{row[:membership]} matched voter ##{matched_voter}")
          user.notes.create!(content: "Original membership type: #{row[:membership]}")
          user.notes.create!(content: "Bid Star!") if row[:membership] == "BidStar"
          fill_in_charge = Charge.cash.successful.create!(
            user: user,
            reservation: reservation_to_upgrade,
            amount: friend_membership.price - reservation_to_upgrade.membership.price,
            comment: "Applying #{row[:membership]} payment to upgrade to #{friend_membership}"
          )
          fill_in_charge.save!
          SetMembership.new(reservation_to_upgrade, to: friend_membership, audit_by: "voter import").call
          update_reservation_contact(row, reservation_to_upgrade)
          p "Matched #{user.email} #{row[:membership]} to voter #{matched_voter} 1:1"
        elsif matched_voters.present?
          # option 2b
          matched_voter = matched_voters.each.next[:conzealand_membership_number]
          reservation_to_upgrade = remembered_reservations[matched_voter]
          user = reservation_to_upgrade.user

          user.notes.create!(content: "#{row[:membership]} matched multiple voters: #{matched_voters}, upgrading ##{matched_voter}")
          user.notes.create!(content: "Original membership type: #{row[:membership]}")
          user.notes.create!(content: "Bid Star!") if row[:membership] == "BidStar"
          fill_in_charge = Charge.cash.successful.create!(
            user: user,
            reservation: reservation_to_upgrade,
            amount: friend_membership.price - reservation_to_upgrade.membership.price,
            comment: "Applying #{row[:membership]} payment to upgrade to #{friend_membership}"
          )
          fill_in_charge.save!
          SetMembership.new(reservation_to_upgrade, to: friend_membership, audit_by: "voter import").call
          update_reservation_contact(row, reservation_to_upgrade)
          p "Matched #{user.email} #{row[:membership]} to voter #{matched_voter} as a guess"
        else
          # option 3
          supporting = create_supporting(row)
          supporting.user.notes.create!(content: "#{row[:membership]} could not be matched to any voter due to no name match")
          p "no voter: #{supporting.user.email} #{member_row_name(row)}"
        end
      elsif voter_entries.nil?
        # option 3
        supporting = create_supporting(row)
        supporting.user.notes.create!(content: "#{row[:membership]} could not be matched to any voter due to no email match")
        p "no voter: #{supporting.user.email} #{member_row_name(row)}"
      else
        # option 2a
        supporting = create_supporting(row)
        supporting.user.notes.create!(content: "Unable to match member name to the voting rolls accurately. Supporting membership #{supporting.membership_number}")
        p "no match: #{supporting.user.email} #{member_row_name(row)}, #{voter_entries}"
      end
    end
  end

  def update_reservation_contact(row, reservation)
    contact = reservation.active_claim.contact
    update_contact(row, contact)
    contact.email = reservation.user.email
    contact.as_import.save!
  end

  def update_contact(row, contact)
    np = People::NameParser.new
    # let's try to parse the legal name
    name = np.parse(row[:legal_name])
    if name[:parsed]
      first_name = name[:first]
      last_name = name[:last]
    else
      first_name = row[:public_first_name]
      last_name = row[:public_last_name]
    end

    pubs_format = if row[:contact_prefs].present? && JSON.parse(row[:contact_prefs])["snailmail"]
                    ChicagoContact::PAPERPUBS_BOTH
                  else
                    ChicagoContact::PAPERPUBS_ELECTRONIC
                  end

    publish_name = row[:public_first_name].present?

    contact.assign_attributes(
      first_name: first_name,
      last_name: last_name,
      preferred_first_name: row[:public_first_name],
      preferred_last_name: row[:public_last_name],
      badge_title: row[:badge_text],
      show_in_listings: publish_name,
      share_with_future_worldcons: publish_name,
      address_line_1: row[:address],
      city: row[:city],
      province: row[:state],
      country: row[:country],
      postal: row[:postcode],
      publication_format: pubs_format,
    )
  end

  def create_supporting(row)
    begin
      user = User.find_or_create_by!(email: row[:email])
      reservation = ClaimMembership.new(nonvoting_friend_membership, customer: user).call
    rescue
      p row
      raise
    end
    reservation.update!(state: Reservation::PAID)

    contact = ChicagoContact.new(
      claim: reservation.active_claim,
      email: user.email,
    )

    update_contact(row, contact)
    contact.as_import.save!

    user.notes.create!(content: "Original membership type: #{row[:membership]}")
    user.notes.create!(content: "Bid Star!") if row[:membership] == "BidStar"

    charge = Charge.cash.successful.create!(
      user: user,
      reservation: reservation,
      amount: nonvoting_friend_membership.price,
      comment: "Implied supporter payment from nonvoting #{row[:membership]}"
    )
    charge.save!

    reservation
  end

  def member_row_name(row)
    np = People::NameParser.new
    name = np.parse(row[:legal_name])
    if name[:parsed]
      first_name = name[:first]
      last_name = name[:last]
    else
      first_name = row[:public_first_name]
      last_name = row[:public_last_name]
    end
    "#{first_name} #{last_name}".strip
  end

  def name_options(input_name)
    name_parts = People::NameParser.new.parse(input_name)
    [input_name, "#{name_parts[:first]} #{name_parts[:last]}".strip]
  end

  def voters_by_email
    @voters_by_email ||= voters.select{ |row| row[:email].present? }.group_by{ |row| row[:email].downcase.strip }
  end

  def person_payments
    @person_payments ||= payments.group_by{|row| row[:person_id]}
  end

  def voter_membership
    @voter_membership ||= Membership.find_by!(name: "supporting")
  end

  def friend_membership
    @friend_membership ||= Membership.find_by!(name: "adult")
  end

  def nonvoting_friend_membership
    @nonvoting_friend_membership ||= Membership.find_by!(name: "supporting")
  end
end
