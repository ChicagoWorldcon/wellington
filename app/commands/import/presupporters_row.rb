# frozen_string_literal: true

# Copyright 2018 Andrew Esler
# Copyright 2019 Matthew B. Gray
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Used in 2020 for importing Presupporters from a spreadsheet
# Can be nuked or adapted as it is no longer required
class Import::PresupportersRow
  HEADINGS = [
    "Timestamp",
    "Title",
    "Given Name",
    "Family Name",
    "Display Given Name",
    "Display Family Name",
    "BadgeTitle",
    "BadgeSubtitle",
    "Address Line1",
    "Address Line2",
    "City",
    "Province/State",
    "Postal/Zip Code",
    "Country",
    "Email Address",
    "Listings",
    "Use Real Name",
    "Use Badge",
    "Share detalis?",
    "Share With Future Worldcons",
    "No electronic publications",
    "Paper Publications",
    "Volunteering",
    "Accessibility Services",
    "Being on Program",
    "Dealers",
    "Selling at Art Show",
    "Exhibiting",
    "Performing",
    "Notes",
    "Import Key",
    "Pre-Support Status",
    "Membership Status",
    "Kiwi Pre-Support and Voted in Site Selection",
  ].freeze

  MEMBERSHIP_LOOKUP = {
    "Adult Attending":          "adult",
    "Child Attending":          "child",
    "Kiwi Pre-Support":         "kiwi",
    "Pre-Opposing":             "pre_oppose",
    "Pre-Supporting":           "pre_support",
    "Silver Fern Pre-Support":  "silver_fern",
    "Supporting":               "supporting",
    "Tuatara Pre-Support":      "tuatara",
    "Young Adult Attending":    "young_adult",
  }.with_indifferent_access.freeze

  attr_reader :row_data, :comment, :fallback_email

  def initialize(row_data, comment:, fallback_email:)
    @row_data = row_data
    @comment = comment
    @fallback_email = fallback_email
  end

  def call
    Claim.transaction do
      new_user = User.find_or_create_by(email: email_address)
      if !new_user.valid?
        errors << new_user.errors.full_messages.to_sentence
        return false
      end

      if !membership.present?
        errors << "missing membership level"
        return false
      end

      new_reservation = ClaimMembership.new(membership, customer: new_user).call
      if !new_reservation
        errors << "could not reserve membership"
        return false
      end

      contact = ConzealandContact.new(
        claim:                            new_reservation.active_claim,
        import_key:                       cell_for("Import Key"),
        title:                            cell_for("Title"),
        first_name:                       cell_for("Given Name"),
        last_name:                        cell_for("Family Name"),
        preferred_first_name:             cell_for("Display Given Name"),
        preferred_last_name:              cell_for("Display Family Name"),
        badge_title:                      cell_for("BadgeTitle"),
        badge_subtitle:                   cell_for("BadgeSubtitle"),
        address_line_1:                   cell_for("Address Line1"),
        address_line_2:                   cell_for("Address Line2"),
        city:                             cell_for("City"),
        province:                         cell_for("Province/State"),
        postal:                           cell_for("Postal/Zip Code"),
        country:                          cell_for("Country"),
        publication_format:               preferred_publication_format,
        show_in_listings:                 cell_for("Listings"),
        share_with_future_worldcons:      cell_for("Share With Future Worldcons"),
        interest_volunteering:            cell_for("Volunteering"),
        interest_accessibility_services:  cell_for("Accessibility Services"),
        interest_being_on_program:        cell_for("Being on Program"),
        interest_dealers:                 cell_for("Dealers"),
        interest_selling_at_art_show:     cell_for("Selling at Art Show"),
        interest_exhibiting:              cell_for("Exhibiting"),
        interest_performing:              cell_for("Performing"),
        created_at:                       import_date,
        updated_at:                       import_date,
      ).as_import

      if !contact.valid?
        errors << contact.errors.full_messages.to_sentence
        return false
      end

      new_reservation.transaction do
        new_reservation.update!(state: Reservation::PAID)
        contact.save!

        new_user.notes.create!(content: comment)
        new_user.notes.create!(content: cell_for("Notes")) if cell_for("Notes").present?

        if membership.price > 0
          Charge.cash.successful.create!(
            user: new_user,
            buyable: new_reservation,
            amount: membership.price,
            comment: comment,
          )
        end

        if account_credit.present?
          Charge.cash.successful.create!(
            user: new_user,
            buyable: new_reservation,
            amount: account_credit.amount,
            comment: "Account credit: #{account_credit.comment}",
          )
        end

        new_reservation.update!(created_at: import_date, updated_at: import_date)
        new_reservation.charges.reload.update_all(created_at: import_date, updated_at: import_date)
        new_reservation.orders.reload.update_all(created_at: import_date, updated_at: import_date, active_from: import_date)
        new_reservation.claims.reload.update_all(created_at: import_date, updated_at: import_date, active_from: import_date)
      end
    end
  end

  def errors
    @errors ||= []
  end

  def error_message
    errors.to_sentence
  end

  private

  def preferred_publication_format
    if electronic_paperpubs? && mail_paperpubs?
      ConzealandContact::PAPERPUBS_BOTH
    elsif electronic_paperpubs?
      ConzealandContact::PAPERPUBS_ELECTRONIC
    elsif mail_paperpubs?
      ConzealandContact::PAPERPUBS_MAIL
    else
      ConzealandContact::PAPERPUBS_NONE
    end
  end

  def electronic_paperpubs?
    case cell_for("No electronic publications")
    when "TRUE"
      false
    when "FALSE"
      true
    else
      errors << cell_for("Invalid input '#{cell_for("No electronic publications")}' for 'No electronic publications'")
    end
  end

  def mail_paperpubs?
    case cell_for("Paper Publications")
    when "TRUE"
      true
    when "FALSE"
      false
    else
      errors << cell_for("Invalid input '#{cell_for("Paper Publications")}' for 'Paper Publications'")
    end
  end

  def membership
    import_string = cell_for("Membership Status")
    membership_name = MEMBERSHIP_LOOKUP[import_string] || import_string
    Membership.find_by(name: membership_name)
  end

  def email_address
    lookup = cell_for("Email Address")
    if lookup.present?
      lookup.downcase.strip
    else
      fallback_email
    end
  end

  def account_credit
    if cell_for("Kiwi Pre-Support and Voted in Site Selection") == "TRUE"
      OpenStruct.new(
        amount: Money.new(50_00),
        comment: "voted in site selection and held kiwi membership"
      )
    end
  end

  def import_date
    return @import_date if @import_date.present?

    if cell_for("Timestamp").present?
      @import_date = cell_for("Timestamp").to_datetime
    else
      @import_date = DateTime.now
    end
  end

  def cell_for(column)
    offset = HEADINGS.index(column)
    row_data[offset]&.strip
  end
end
