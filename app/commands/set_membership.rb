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

# SetMembership is a Support user function, used to set a membership to any level and evaluate if it's been paid off yet
# If this does fail, it's going to 500 and roll back
class SetMembership
  attr_reader :reservation, :to_membership, :audit_by, :amount_owing

  def initialize(reservation, to: nil, audit_by: nil)
    @reservation = reservation
    @to_membership = to
    @audit_by = audit_by
  end

  def call
    reservation.transaction do
      as_at = Time.now
      create_audit_note if audit_by.present?
      log_last_fully_paid_membership
      disable_existing_order(as_at)
      create_new_order(as_at)

      # Drop AR caches to #membership and related has_many through relations
      reservation.reload
      revise_reservation_status(reservation)
    end
  end

  private

  def disable_existing_order(as_at)
    reservation.active_order.update!(active_to: as_at)
  end

  def create_new_order(as_at)
    reservation.orders.create!(active_from: as_at, membership: to_membership)
  end

  def log_last_fully_paid_membership
    credit = AmountOwedForReservation.new(@reservation).current_credit.cents

    last_paid_array = []

    last_paid_array << @reservation.last_fully_paid_membership if @reservation.last_fully_paid_membership.present?
    last_paid_array << @reservation.membership if @reservation.membership.price_cents <= credit

    #If the current membership is less expensive than the one logged as last_fully_paid_membership, we want don't want to change the logging.
    last_paid_array.sort_by { |membership| membership.price_cents }
    @reservation.update!(last_fully_paid_membership: last_paid_array[0])
    @reservation.reload
  end

  def revise_reservation_status(our_res)
    if fully_paid?
      our_res.update!(state: Reservation::PAID)
    else
      our_res.update!(state: Reservation::INSTALMENT)
    end
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
    AmountOwedForReservation.new(@reservation).amount_owed <= 0
  end
end
