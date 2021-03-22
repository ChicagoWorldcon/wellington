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

# ClaimMembership creates a relationship between a User and a Membership
# It creates associated records and sets state to make those things active
# See the models directory for what each of these things represents
# If this does fail, it's going to 500 and roll back
class ClaimMembership
  FIRST_MEMBERSHIP_NUMER = 100

  attr_reader :customer, :membership, :membership_number

  def initialize(membership, customer:, membership_number: nil)
    @customer = customer
    @membership = membership
    @membership_number = membership_number
  end

  def call
    ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      Reservation.lock # pessimistic membership number uniqueness
      as_at = Time.now
      reservation = Reservation.create!(
        membership_number: (membership_number || next_membership_number),
        state: (membership.price.zero? ? Reservation::PAID : Reservation::INSTALMENT)
      )
      Order.create!(active_from: as_at, membership: membership, reservation: reservation)
      Claim.create!(active_from: as_at, user: customer, reservation: reservation)
      reservation
    end
  end

  private

  def next_membership_number
    if last_number = Reservation.maximum(:membership_number)
      last_number + 1
    else
      FIRST_MEMBERSHIP_NUMER
    end
  end
end
