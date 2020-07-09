# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
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

class Export::MembershipRow
  # JOINS describe fields needed to be preloaded on Detail for speed
  # These are tied to the Detail model
  JOINS = {
    claim: [
      :user,
      { reservation: :membership },
    ]
  }.freeze

  CONTACT_KEYS = ChicagoContact.new.attributes.keys.freeze

  HEADINGS = [
    "membership_number",
    "email",
    "membership_name",
    "name_to_list",
    *CONTACT_KEYS,
  ].freeze

  attr_reader :contact

  def initialize(contact)
    @contact = contact
  end

  def values
    reservation = contact.claim.reservation
    contact_values = contact.slice(CONTACT_KEYS).values.map(&:to_s)

    [
      reservation.membership_number,
      contact.claim.user.email,
      reservation.membership.name,
      contact.to_s,
      *contact_values,
    ]
  end
end
