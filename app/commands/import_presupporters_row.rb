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

class ImportPresupportersRow
  HEADINGS = [
    "Timestamp",
    "Title",
    "Full name",
    "PreferredFirstname",
    "PreferedLastname",
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
    "Master Membership Status",
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

      new_purchase = PurchaseMembership.new(membership, customer: new_user).call
      if !new_purchase
        errors << "could not purchase membership"
        return false
      end

      details = Detail.new(
        claim:                            new_purchase.active_claim,
        import_key:                       cell_for("Import Key"),
        full_name:                        cell_for("Full name"),
        preferred_first_name:             cell_for("PreferredFirstname"),
        prefered_last_name:               cell_for("PreferedLastname"),
        badgetitle:                       cell_for("BadgeTitle"),
        badgesubtitle:                    cell_for("BadgeSubtitle"),
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
      ).as_import

      if !details.valid?
        errors << details.errors.full_messages.to_sentence
        return false
      end

      new_purchase.transaction do
        new_purchase.update!(state: Purchase::PAID)
        details.save!
        if cell_for("Notes").present?
          new_user.notes.create!(content: cell_for("Notes"))
        end
        Charge.cash.successful.create!(
          user: new_user,
          purchase: new_purchase,
          amount: membership.price,
          comment: comment,
        )
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
      Detail::PAPERPUBS_BOTH
    elsif electronic_paperpubs?
      Detail::PAPERPUBS_ELECTRONIC
    elsif mail_paperpubs?
      Detail::PAPERPUBS_MAIL
    else
      Detail::PAPERPUBS_NONE
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

  def cell_for(column)
    offset = HEADINGS.index(column)
    row_data[offset]
  end
end
