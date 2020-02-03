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

class MergeMembership
  attr_reader :reservations, :numbers, :errors

  def initialize(reservations)
    @reservations = reservations
    @numbers = reservations.map(&:membership_number)
    @errors = []
  end

  def call
    assert_ownership
    assert_only_2_memberships

    if errors.none?
      to_keep.transaction do
        to_remove.active_claim.update!(active_to: 1.second.ago)

        # We need to do this dance because memberships can't have the same number
        to_remove.update!(membership_number: -1)
        to_keep.update!(membership_number: -2)
        to_remove.update!(membership_number: numbers.max)
        to_keep.update!(membership_number: numbers.min)
      end
    end

    errors.none?
  end

  private

  def to_keep
    return @to_keep if @to_keep.present?

    membership_reservations = Reservation.where(id: reservations).joins(:membership)
    highest_price = membership_reservations.maximum("memberships.price_cents")
    @to_keep = membership_reservations.find_by!(memberships: {price_cents: highest_price})
  end

  def to_remove
    (reservations - [to_keep]).first
  end

  def assert_ownership
    if reservations.map(&:user).uniq.count > 1
      errors << "memberships need to be owned by the same user"
    end
  end

  def assert_only_2_memberships
    count = reservations.count
    if count != 2
      errors << "you can only merge 2 memberships, got #{count}"
    end
  end
end
