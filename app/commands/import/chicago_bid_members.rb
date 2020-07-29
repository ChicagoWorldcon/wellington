require "people"

class Import::ChicagoBidMembers

  # import a chicago bid member dump. All we're doing here is creating new users if needed, and then creating a paid
  # reservation for them.

  attr_reader :people, :payments, :description, :errors

  def initialize(people_csv, payments_csv, description)
    @description = description
    @errors = []
    @people = people_csv  # must have headers
    @payments = payments_csv # must have headers
  end

  def call
    np = People::NameParser.new
    people.each do |row|
      next unless ["BidFriend", "BidStar"].include? row[:membership]

      email = row[:email].downcase.strip
      user = User.find_or_create_by!(email: email)
      reservation = ClaimMembership.new(chicago_membership, customer: user).call
      reservation.update!(state: Reservation::PAID)

      # let's try to parse the legal name
      name = np.parse(row[:legal_name])
      if name[:parsed]
        first_name = name[:first]
        last_name = name[:last]
      else
        first_name = row[:public_first_name]
        last_name = row[:public_last_name]
      end

      contact = ChicagoContact.new(
        claim: reservation.active_claim,
        first_name: first_name,
        last_name: last_name,
        preferred_first_name: row[:public_first_name],
        preferred_last_name: row[:public_last_name],
        badge_title: row[:badge_text],
        share_with_future_worldcons: false,
        show_in_listings: row[:public_first_name].present?,
        address_line_1: row[:address],
        city: row[:city],
        province: row[:state],
        country: row[:country],
        postal: row[:postcode],
        publication_format: ChicagoContact::PAPERPUBS_ELECTRONIC,
        email: user.email,
      )
      contact.as_import.save!

      user.notes.create!(content: "#{description}")
      user.notes.create!(content: "Original membership type: #{row[:membership]}")
      user.notes.create!(content: "Bid Star!") if row[:membership] == "BidStar"

      next unless person_payments[row[:id]].present?

      attending_payment_contribution = 120_00
      payment_total = 0
      person_payments[row[:id]].each do |payment|
        next unless payment[:stripe_charge_id].present?
        next unless payment[:status] == "succeeded"
        next if payment_total >= attending_payment_contribution

        if payment_total + payment[:amount] <= attending_payment_contribution
          payment_amount = payment[:amount]
        else
          payment_amount = attending_payment_contribution - payment_total
          p "User #{email} trimmed payment #{payment[:amount]} to #{payment_amount}"
        end

        charge = Charge.stripe.successful.create!(
          user: user,
          reservation: reservation,
          stripe_id: payment[:stripe_charge_id],
          amount: payment_amount,
          comment: "Imported payment from bid: payment_id=#{payment[:id]}, original amount=#{payment[:amount]}"
        )
        charge.save!
        payment_total += payment_amount
      end
    end
  end

  def person_payments
    @person_payments ||= build_person_payments
  end

  def build_person_payments
    payments.group_by{|row| row[:person_id]}
  end

  def chicago_membership
    @chicago_membership ||= Membership.find_by!(name: "friend")
  end

end
