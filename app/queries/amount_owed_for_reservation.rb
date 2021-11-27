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

  attr_reader :reservation, :current_credit

  def initialize(reservation)
    @reservation = reservation
    @current_credit = calculate_current_credit
  end

  def amount_owed
    Money.new(@reservation.membership.price_cents - @current_credit.to_i)
  end

  def successful_direct_charge_total
    @reservation.charges.successful.exists? ? @reservation.charges.successful.sum(&:amount) : 0
  end

  def fully_paid_by_cart?
    cart_associated? && total_cents_owed_for_related_carts <= 0
  end

  private

  def calculate_current_credit
    successful_direct_charge_total + previous_cart_charge_credit
  end

  def carts_related_to_reservation
    Cart.joins(:cart_items).where(cart_items: {holdable: @reservation})
  end

  def cart_associated?
    carts_related_to_reservation.exists?
  end

  def total_cents_owed_for_related_carts
    owed = 0
    carts_related_to_reservation.to_ary.each do |c|
      owed += CentsOwedForCartContents.new(c).owed_cents
    end
    owed
  end

  def previous_cart_charge_credit
    return 0 unless fully_paid_by_cart?
    return @reservation.last_fully_paid_membership.price_cents if  @reservation.last_fully_paid_membership.present?
    @reservation.membership.price_cents
  end
end
