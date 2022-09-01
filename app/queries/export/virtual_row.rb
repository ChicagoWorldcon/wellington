# frozen_string_literal: true

# Copyright 2022 Chris Rose
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

class Export::VirtualRow
  # JOINS describe fields needed to be preloaded on Detail for speed
  # These are tied to the Detail model
  JOINS = {
    claim: [
      :user,
      { reservation: :membership }
    ]
  }.freeze

  CONTACT_KEYS = ChicagoContact.new.attributes.keys.freeze

  HEADINGS = [
    "First Name",
    "Last Name",
    "Email",
    "City",
    "Country"
  ].freeze

  attr_reader :contact

  def initialize(contact)
    @contact = contact
  end

  def values
    # reservation = contact.claim.reservation
    # contact_values = contact.slice(CONTACT_KEYS).values.map(&:to_s)

    if contact.badge_title.present?
      contact_first_name = contact.badge_title
      contact_last_name = "."
    elsif contact.preferred_first_name.present?
      contact_first_name = contact.preferred_first_name
      contact_last_name = contact.preferred_last_name || "."
    else
      contact_first_name = contact.first_name
      contact_last_name = contact.last_name || "."
    end

    [
      contact_first_name,
      contact_last_name,
      contact.email || contact.claim.user.email,
      contact.city,
      contact.country
    ]
  end
end
