# frozen_string_literal: true
#
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

# Given a Row from a CSV, creates associated records
# Used in 2020 for importing from Kansa
# Can be nuked or adapted as is no longer being depended on
class Import::KansaMembersRow
  HEADINGS = [
    "Full name",
    "PreferredFirstname",
    "PreferedLastname",
    "BadgeTitle",
    "BadgeSubtitle",
    "Address Line1",
    "Address Line2",
    "Country",
    "Email Address",
    "Notes",
    "Membership Status",
    "Stripe Payment ID",
    "Charge Amount",
    "Payment Comment",
    "Member Number",
    "Created At",
  ].freeze

  MEMBERSHIP_LOOKUP = {
    "Adult Attending":          "adult",
    "Child Attending":          "child",
    "Child":                    "child",
    "Kiwi Pre-Support":         "kiwi",
    "Pre-Opposing":             "pre_oppose",
    "Pre-Supporting":           "pre_support",
    "Silver Fern Pre-Support":  "silver_fern",
    "Supporting":               "supporting",
    "Tuatara Pre-Support":      "tuatara",
    "Young Adult Attending":    "young_adult",
    "Adult":                    "adult",
    "Supporter":                "supporting",
    "Unwaged":                  "unwaged",
    "KidInTow":                 "kid_in_tow",
  }.with_indifferent_access.freeze

  attr_reader :row_data, :comment

  def initialize(row_data, comment)
    @row_data = row_data
    @comment = comment
  end

  def call
    new_user = User.find_or_create_by_canonical_email(cell_for("Email Address"))
    unless new_user.valid?
      errors << new_user.errors.full_messages.to_sentence
      return false
    end

    note = cell_for("Notes")
    new_user.notes.create!(content: note) if note.present?

    membership_number = cell_for("Member Number")
    membership_record = lookup_membership
    if !membership_record.present?
      errors << "can't find membership_record"
      return false
    end

    command = ClaimMembership.new(membership_record, customer: new_user, membership_number: membership_number)
    new_reservation = command.call

    if !new_reservation
      errors << command.error_message
      return false
    end

    name_splitter = Import::KansaNameSplitter.new(cell_for("Full name"))

    contact = ConzealandContact.new(
      claim:                            new_reservation.active_claim,
      title:                            name_splitter.title,
      first_name:                       name_splitter.first_name,
      last_name:                        name_splitter.last_name,
      preferred_first_name:             cell_for("PreferredFirstname"),
      preferred_last_name:              cell_for("PreferedLastname"),
      badge_title:                      cell_for("BadgeTitle"),
      badge_subtitle:                   cell_for("BadgeSubtitle"),
      address_line_1:                   cell_for("Address Line1"),
      address_line_2:                   cell_for("Address Line2"),
      country:                          cell_for("Country"),
      publication_format:               ConzealandContact::PAPERPUBS_ELECTRONIC,
      created_at:                       import_date,
      updated_at:                       import_date,
    ).as_import

    # This should be opt in, people need to have seen the checkbox to have accepted these terms.
    # As this didn't exist in Kansa, we're setting it to false here. Forms going forward will have these set.
    contact[:show_in_listings] = false
    contact[:share_with_future_worldcons] = false

    if !contact.valid?
      errors << contact.errors.full_messages.to_sentence
      return false
    end

    new_reservation.transaction do
      if new_reservation.instalment? && cell_for("Charge Amount").to_i > 0
        Charge.stripe.successful.create!(
          user: new_user,
          buyable: new_reservation,
          amount_cents: cell_for("Charge Amount"),
          stripe_id: cell_for("Stripe Payment ID"),
          comment: cell_for("Payment Comment"),
        )
        new_reservation.update!(state: Reservation::PAID)
      end

      contact.save!
      new_reservation.update!(created_at: import_date, updated_at: import_date)
      new_reservation.charges.reload.update_all(created_at: import_date, updated_at: import_date)
      new_reservation.orders.reload.update_all(created_at: import_date, updated_at: import_date, active_from: import_date)
      new_reservation.claims.reload.update_all(created_at: import_date, updated_at: import_date, active_from: import_date)
    end

    errors.none?
  end

  def errors
    @errors ||= []
  end

  def error_message
    errors.to_sentence
  end

  private

  def lookup_membership
    import_string = cell_for("Membership Status")
    membership_name = MEMBERSHIP_LOOKUP[import_string] || import_string
    Membership.find_by(name: membership_name)
  end

  def import_date
    return @import_date if @import_date.present?

    if cell_for("Created At").present?
      @import_date = cell_for("Created At").to_datetime
    else
      @import_date = DateTime.now
    end
  end

  def cell_for(column)
    offset = HEADINGS.index(column)
    row_data[offset]&.strip
  end
end
