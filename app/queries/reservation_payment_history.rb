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

# ReservationPaymentHistory outputs an array of ordered enums that show the history of payments on a reservation.
class ReservationPaymentHistory
  attr_reader :our_reservation

  def initialize(reservation)
    @our_reservation = reservation
  end

  def history_array
    all_charges_combined.to_ary
  end

  def all_charges_combined
    Charge.where(buyable: @our_reservation).or(Charge.where(buyable: carts_related_to_reservation)).order(created_at: :desc)
  end

  def successful_charges_combined
    Charge.successful.where(buyable: @our_reservation).or(Charge.successful.where(buyable: carts_related_to_reservation)).order(created_at: :desc)
  end

  def any_charges?
    all_charges_combined.present?
  end

  def any_successful_charges?
    successful_charges_combined.present?
  end

  def all_direct_charges
    Charge.where(buyable: @our_reservation).order(created_at: :desc)
  end

  def all_cart_charges
    Charge.where(buyable: carts_related_to_reservation).order(created_at: :desc)
  end

  def successful_direct_charges
    Charge.successful.where(buyable: @our_reservation).order(created_at: :desc)
  end

  def successful_cart_charges
    Charge.successful.where(buyable: carts_related_to_reservation).order(created_at: :desc)
  end


  private

  def carts_related_to_reservation
    Cart.joins(:cart_items).where(cart_items: {holdable: @our_reservation})
  end
end
