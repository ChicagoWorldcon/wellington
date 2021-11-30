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
    price = Money.new(@reservation.membership.price_cents)
    credit = Money.new(@current_credit)
    price - credit
  end

  def successful_direct_charge_total
    s_dirs = @reservation.charges.successful.exists? ? @reservation.charges.successful.sum(&:amount) : 0
    returnable = Money.new(s_dirs)
    returnable
  end

  def fully_paid_by_cart?
    cart_associated? && charges_for_related_carts_present? && total_cents_owed_for_related_carts <= 0
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

  def charges_for_related_carts_present?
    carts_related_to_reservation.to_ary.each do |c|
      return true if c.charges.successful.exists?
    end
    false
  end

  def total_cents_owed_for_related_carts
    owed = 0
    carts_related_to_reservation.to_ary.each do |c|
      owed += CentsOwedForCartContents.new(c).owed_cents
    end
    owed
  end

  def previous_cart_charge_credit
    return Money.new(0) unless fully_paid_by_cart?
    return Money.new(@reservation.last_fully_paid_membership.price_cents) if  @reservation.last_fully_paid_membership.present?
    Money.new(@reservation.membership.price_cents)
  end
end
