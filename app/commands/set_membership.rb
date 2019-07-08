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

class SetMembership
  attr_reader :reservation, :to_membership, :audit_by

  def initialize(reservation, to:, audit_by: nil)
    @reservation = reservation
    @to_membership = to
    @audit_by = audit_by
  end

  def call
    reservation.transaction do
      as_at = Time.now

      create_audit_note if audit_by.present?
      disable_existing_order(as_at)
      create_new_order(as_at)

      # Drop AR caches to #membership and related has_many through relations
      reservation.reload

      if fully_paid?
        reservation.update!(state: Reservation::PAID)
      else
        reservation.update!(state: Reservation::INSTALMENT)
      end
    end
  end

  private

  def disable_existing_order(as_at)
    reservation.active_order.update!(active_to: as_at)
  end

  def create_new_order(as_at)
    reservation.orders.create!(active_from: as_at, membership: to_membership)
  end

  def create_audit_note
    reservation.user.notes.create!(
      content: %{
        #{audit_by} set membership
        for ##{reservation.membership_number}
        from #{reservation.membership}
        to #{to_membership}
      }
    )
  end

  def fully_paid?
    AmountOwedForReservation.new(reservation).amount_owed <= 0
  end
end
