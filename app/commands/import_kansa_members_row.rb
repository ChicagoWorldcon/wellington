# Copyright 2018 Matthew B. Gray
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

class ImportKansaMembersRow
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
    "Membership Number",
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

  attr_reader :row_data, :comment

  def initialize(row_data, comment)
    @row_data = row_data
    @comment = comment
  end

  def call
    new_user = User.new(email: cell_for("Email Address"))
    if !new_user.valid?
      errors << new_user.errors.full_messages.to_sentence
      return false
    end

    note = cell_for("Notes")
    new_user.notes.build(content: note) if !note.nil?

    membership_number = cell_for("Membership Number")
    command = PurchaseMembership.new(membership, customer: new_user, membership_number: membership_number)
    new_purchase = command.call

    if !new_purchase
      errors << command.error_message
      return false
    end

    new_purchase.update!(state: Purchase::PAID)
    Charge.stripe.successful.create!(
      user: new_user,
      purchase: new_purchase,
      amount: cell_for("Charge Amount"),
      stripe_id: cell_for("Stripe Payment ID"),
      comment: cell_for("Payment Comment"),
    )

    errors.none?
  end

  def errors
    @errors ||= []
  end

  def error_message
    errors.to_sentence
  end

  private

  def membership
    import_string = cell_for("Membership Status")
    membership_name = MEMBERSHIP_LOOKUP[import_string] || import_string
    Membership.find_by!(name: membership_name)
  end

  def cell_for(column)
    offset = HEADINGS.index(column)
    row_data[offset]
  end
end
