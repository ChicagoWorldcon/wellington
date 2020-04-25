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

# Export::NominationRow gathers information for export based on requests from Hugo Admins
class Export::NominationRow
  # JOINS describe fields needed to be preloaded on Nomination for speed
  # These are tied to the Nominations model
  JOINS = [
    # reservation: { active_claim: :conzealand_contact },
    reservation: :user
  ].freeze

  HEADINGS = %w[
    users.current_sign_in_ip
    users.last_sign_in_ip

    users.current_sign_in_at
    users.last_sign_in_at
    contact.updated_at
    users.created_at
    contact.created_at
    nominations.created_at

    reservations.membership_number
    users.email
    users.sign_in_count
    contact.preferred_first_name
    contact.preferred_last_name
    contact.title
    contact.first_name
    contact.last_name
    categories.name
    nominations.field_1
    nominations.field_2
    nominations.field_3
  ].freeze

  attr_reader :nomination

  def initialize(nomination)
    @nomination = nomination
  end

  # The cop triggered here thinks there's too many assignments
  # But this is expected for an export
  # rubocop:disable Metrics/AbcSize
  def values
    [
      user.current_sign_in_ip,
      user.last_sign_in_ip,

      user.current_sign_in_at,
      user.last_sign_in_at,
      contact.updated_at,
      user.created_at,
      contact.created_at,
      nomination.created_at,

      reservation.membership_number,
      user.email,
      contact.preferred_first_name,
      contact.preferred_last_name,
      contact.title,
      contact.first_name,
      contact.last_name,
      nomination.category.name,
      nomination.field_1,
      nomination.field_2,
      nomination.field_3
    ]
  end
  # rubocop:enable Metrics/AbcSize

  private

  def reservation
    nomination.reservation
  end

  def contact
    reservation.active_claim.conzealand_contact
  end

  def user
    reservation.user
  end
end
