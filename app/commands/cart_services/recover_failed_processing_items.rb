# frozen_string_literal: true
#
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


class CartServices::RecoverFailedProcessingItems

  MEMBERSHIP = CartItem::MEMBERSHIP
  PENDING = Cart::PENDING
  PROCESSING = Cart::PROCESSING

  attr_reader :our_cart, :our_user

  def initialize(cart_obj, user)
    @our_cart = identify_our_cart(cart_obj)
    @our_user = user
  end

  def call
    return -1 if !@our_cart.present?
    recovered = 0
    fail_carts = Cart.active_processing.where(user: @our_user).where.not(id: @our_cart.id)

    if fail_carts.present?
      fail_carts.to_ary.each do |f|
        f.cart_items.each do |i|
          if unprocessed_reservation_item?(f, i)
            recovered += 1
            i.cart = @our_cart
            i.save!
          end
        end
        f.reload
        f.status = ::Cart::PAID if mark_failed_cart_paid?(f)
        f.active_to = Time.now if mark_failed_cart_inactive?(f)
        f.save
      end
    end
    @our_cart.reload
    recovered
  end

  private

  def identify_our_cart(c_obj)
    c_obj.now_bin
  end

  def unprocessed_reservation_item?(cart, item)
    return false if (cart.status != PROCESSING || cart.active? == false)
    return true if (item.kind == MEMBERSHIP && !item.item_reservation.present?)
    unprocessed = false
    if (item.item_reservation.present? && ::Reservation::INSTALMENT &&  item.acquirable.price > 0)
      unprocessed = (AmountOwedForReservation.new(item.item_reservation).amount_owed == item.acquirable.price)
    end
    unprocessed
  end

  def mark_failed_cart_paid?(cart)
    cart.reload
    return false if cart.status != PROCESSING
    return false if cart.cart_items.empty?
    mark_paid = true
    cart.cart_items.each do |i|
      if i.item_reservation.present?
        mark_paid = false if (i.item_reservation.state == INSTALMENT) && (AmountOwedForReservation.new(i.item_reservation).amount_owed) > 0
      end
    end
    mark_paid
  end

  def mark_failed_cart_inactive?(cart)
    cart.reload
    return false if cart.status != PROCESSING
    return true if cart.cart_items.empty?
  end

end
