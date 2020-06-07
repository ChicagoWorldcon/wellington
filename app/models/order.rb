# frozen_string_literal: true

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

# Order represents a Membership associated to Reservation even when that Membership isn't active
# User is associated to Order through Reservation
# For instance, instalment payments could continue to be made towards a Membership when it's not being displayed in the store
# New orders are created through import scripts, or commands like UpgradeMembership and ClaimMembership
class Order < ApplicationRecord
  include ActiveScopes

  validates :membership, presence: true
  validates :reservation, presence: true, uniqueness: {
    conditions: -> { active } # There can't be other active orders against the same reservation
  }, if: :active?

  belongs_to :membership
  belongs_to :reservation
end
