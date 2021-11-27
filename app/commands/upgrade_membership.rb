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

# UpgradeMembership command upgrades membership between two levels
# Truthy return means upgrade was successful, otherwise check errors for explanation
class UpgradeMembership < SetMembership

  def call
    check_availability
    return false if errors.any?
    record_previous_paid_membership_memo
    super
  end

  def errors
    @errors ||= []
  end

  private

  def check_availability
    prices = UpgradeOffer.from(reservation.membership, target_membership: to_membership)
    if prices.none?
      errors << "#{reservation.membership} cannot upgrade to #{to_membership}"
    end
  end

  def record_previous_paid_membership_memo
    reservation.update!(last_fully_paid_membership:  reservation.membership) if AmountOwedForReservation.new(@reservation).amount_owed <= 0
    reservation.reload
  end
end
