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

class BuildPersonRow
  ExportError = Class.new(StandardError)
  MEMBER_NUMBER_OFFSET = 100

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

  attr_reader :person

  def initialize(person)
    @person = person
  end

  def to_row
    raise(ExportError, "Person##{person.id} has multiple successful payments") if person.payments.succeeded.count > 1
    raise(ExportError, "Person##{person.id} is missing a payment") if payment.nil?
    raise(ExportError, "Person##{person.id} payment does not match membership") unless person.membership == payment.type
    raise(ExportError, "Person##{person.id} payment is not in NZD") unless payment.currency == "nzd"

    [
      person.legal_name,                           # "Full name",
      person.public_first_name,                    # "PreferredFirstname",
      person.public_last_name,                     # "PreferedLastname",
      person.badge_name,                           # "BadgeTitle",
      person.badge_subtitle,                       # "BadgeSubtitle",
      person.city,                                 # "Address Line1",
      person.state,                                # "Address Line2",
      person.country,                              # "Country",
      person.email,                                # "Email Address",
      "Imported from kansa. People##{person.id}",  # "Notes",
      person.membership,                           # "Membership Status",
      payment.stripe_charge_id,                    # "Stripe Payment ID",
      payment.amount,                              # "Charge Amount"
      payment_comment,                             # "Payment Comment"
      person.member_number + MEMBER_NUMBER_OFFSET, # "Member Number"
      payment.created&.iso8601,                    # "Created At"
    ]
  end

  def payment
    @payment ||= person.payments.succeeded.first
  end

  def payment_comment
    "kansa payment##{payment.id} for #{payment.amount.to_f / 100}#{payment.currency.upcase} paid with token #{payment.stripe_token} for #{payment.type} (#{payment.category})"
  end
end
