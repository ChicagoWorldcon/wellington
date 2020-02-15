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
  JOINS = {
    claim: [
      :user,
      { reservation: :membership },
    ]
  }.freeze

  DETAIL_KEYS = Detail.new.attributes.keys.freeze

  HEADINGS = [
    "membership_number",
    "email",
    "membership_name",
    "name_to_list",
    *DETAIL_KEYS,
  ].freeze

  attr_reader :detail

  def initialize(detail)
    @detail = detail
  end

  def values
    reservation = detail.claim.reservation
    detail_values = detail.slice(DETAIL_KEYS).values.map(&:to_s)

    [
      reservation.membership_number,
      detail.claim.user.email,
      reservation.membership.name,
      detail.to_s,
      *detail_values,
    ]
  end
end
