# frozen_string_literal: true

# Copyright 2021 Victoria Garcia
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

# ReservationsInCart finds all the reservations associated with
# items in the current cart.

class ReservationsInCart
  MEMBERSHIP = CartItem::MEMBERSHIP
  RESERVATION = "Reservation"

  attr_accessor :reservations_found

  def initialize(our_cart)
    @reservations_found = associated_reservations(our_cart)
  end

  private

  def associated_reservations(r_cart)
    Reservation.where(id: CartItem.where(cart: r_cart, kind: "membership").where.not(holdable: nil).select('holdable_id').map(&:holdable_id)).to_ary
  end
end
