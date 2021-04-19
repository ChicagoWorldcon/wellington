# frozen_string_literal: true

# Copyright 2019 AJ Esler
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

# AmountOwedForReservation compares successful Charge records on the Reservation to the cost of a Membership
class AmountOwedForReservation
  PAID = Reservation::PAID

  attr_reader :reservation

  def initialize(reservation)
    @reservation = reservation
  end

  def amount_owed
    # TODO: Figure out if this is adequate
    return Money.new(0) if fully_paid_by_cart?

    paid_so_far = reservation.charges.successful.sum(&:amount)
    reservation.membership.price - paid_so_far
  end

  def fully_paid_by_cart?
    cents_owed_for_associated_carts <= 0
  end

  private

  def carts_related_to_reservation
    Cart.joins(:cart_items).where(cart_items: {holdable: @reservation})
  end

  def cents_owed_for_associated_carts
    owed = 0
    carts_related_to_reservation.to_ary.each do |c|
      owed += CentsOwedForCartContents.new(c).owed_cents
    end
    owed
  end
end
