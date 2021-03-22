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

module CartItemsHelper

  MAX_CHARS_FOR_EMAIL_CART_DESCRIPTION = 10000
  MAX_CHARS_FOR_ONSCREEN_CART_DESCRIPTION = 10000

  MEMBERSHIP = "membership"
  PENDING = "pending"
  PROCESSING = "processing"
  PAID = "paid"

  # TODO: See if this can be eliminated.  There's a new method
  # in MembershipOffer that should handle this.
  def self.locate_offer(offer_params)
    target_offer = MembershipOffer.options.find do |offer|
      offer.hash == offer_params
    end
    if !target_offer.present?
      flash[:error] = t("errors.offer_unavailable", offer: offerParams)
    end
    target_offer
  end

  def locate_offer(offer_params)
    CartItemsHelper.locate_offer(offer_params)
  end

  def self.locate_cart_item(item_id)
    CartItem.find_by(id: item_id)
  end

  def locate_cart_item(item_id)
    CartItemsHelper.locate_cart_item(item_id)
  end

  def self.locate_cart_item_with_cart(item_id, cart_id)
    CartItem.find_by(id: item_id, cart_id: cart_id)
  end

  def locate_cart_item_with_cart(item_id, cart_id)
    CartItemsHelper.locate_cart_item_with_cart(item_id, cart_id)
  end

  def self.cart_items_for_now(cart)
    if cart
      cart.cart_items.select {|i| !i.later}
    else
      return nil
    end
  end

  def cart_items_for_now(cart)
    CartItemsHelper.cart_items_for_now(cart)
  end

  def self.cart_items_for_later(cart)
    if cart.present?
      cart.cart_items.select {|i| i.later}
    else
      return nil
    end
  end

  def cart_items_for_later(cart)
    CartItemsHelper.cart_items_for_later(cart)
  end

  def self.verify_availability_of_cart_contents(cart)
    if cart.present?
      all_contents_available = true;
      cart.cart_items.each do |item|
        if item.item_still_available? == false
          all_contents_available = false
        end
      end
      cart.reload
      return all_contents_available
    else
      return nil
    end
  end

  def verify_availability_of_cart_contents(cart)
    CartItemsHelper.verify_availability_of_cart_contents(cart)
  end

  def self.cart_contents_ready_for_payment?(cart, now_items_only = false)
    all_contents_ready = true
    cart.cart_items.each do |i|
      if (now_items_only && !i.later) || !now_items_only
        all_contents_ready = false if !i.item_ready_for_payment?
      end
    end
    all_contents_ready
  end

  def cart_contents_ready_for_payment?(cart)
    CartItemsHelper.cart_items_ready_for_payment?(cart)
  end

  def self.destroy_cart_contents(cart)
    if cart
      cart.cart_items.each {|i| i.destroy}
      cart.reload
      return cart.cart_items.empty?
    else
      return nil
    end
  end

  def destroy_cart_contents(cart)
    CartItemsHelper.destroy_cart_contents(cart)
  end

  def self.destroy_for_now_cart_items(cart)
    if cart
      now_items = cart_items_for_now(cart)
      now_items.each {|i| i.destroy}
      cart.reload
      return cart_items_for_now(cart).empty?
    else
      return nil
    end
  end

  def destroy_for_now_cart_items(cart)
    CartItemsHelper.destroy_for_now_cart_items(cart)
  end

  def self.destroy_cart_items_for_later(cart)
    if cart
      later_items = cart_items_for_later(cart)
      later_items.each {|i| i.destroy}
      cart.reload
      return cart_items_for_later(cart).empty?
    end
  end

  def destroy_cart_items_for_later(cart)
    CartItemsHelper.destroy_cart_items_for_later(cart)
  end

  def self.save_all_cart_items_for_later(cart)
    if cart
      cart.cart_items.each do  |i|
        i.later = true
        i.save
      end
      cart.reload
      return cart_items_for_now(cart).empty?
    else
      return nil
    end
  end

  def save_all_cart_items_for_later(cart)
    CartItemsHelper.save_all_cart_items_for_later(cart)
  end

  def self.unsave_all_cart_items(cart)
    if cart
      cart.cart_items.each do |i|
        i.later = false
        unless i.save
          flash[:error] = "unable to move #{i.item_display_name} to cart"
          flash[:messages] = i.errors.messages
          all_movable = false
        end
      end
      cart.reload
      return cart_items_for_later(cart).empty?
    else
      return nil
    end
  end

  def unsave_all_cart_items(cart)
    CartItemsHelper.unsave_all_cart_items(cart)
  end

  def self.locate_all_membership_items(cart)
    if cart.present?
      cart.cart_items.select {|i| i.kind == MEMBERSHIP}
    else
      return nil
    end
  end

  def locate_all_membership_items(cart)
    CartItemsHelper.locate_all_membership_items(cart)
  end

  def self.locate_all_membership_items_for_now(cart)
    if cart.present?
      cart.cart_items.select {|i| i.kind == MEMBERSHIP && i.later == false}
    else
      return nil
    end
  end

  def locate_all_membership_items_for_now(cart)
    CartItemsHelper.locate_all_membership_items(cart)
  end

  #TODO: Figure out how much of this failed processing recovery stuff we need or want.

  def self.recover_failed_processing_items(cart, user)
    recovered = 0
    if cart.present? && user.present?
      fail_carts = Cart.active_processing.where(user: user).where.not(id: cart.id)
      if fail_carts.present?
        fail_carts.to_ary.each do |f|
          f.cart_items.each do |i|
            if unprocessed_reservation_item?(f, i)
              recovered += 1
              i.cart = cart
              i.save!
            end
          end
          f.reload
          f.status = ::Cart::PAID if mark_failed_cart_paid?(f)
          f.active_to = Time.now if mark_failed_cart_inactive?(f)
          f.save
          # TODO: GET RID OF THIS-- it's just for development
          if f.active_and_processing == true
            f.cart_items.each {|i|
            puts "destroying cart item #{i.id}"
            i.destroy }
            puts "destroying cart #{f}"
            f.destroy
          end
        end
      end
      cart.reload
    end
    recovered
  end

  def recover_failed_processing_items(cart, user)
    CartItemsHelper.recover_failed_processing_items(cart, user)
  end

  def self.unprocessed_reservation_item?(cart, item)
    return false if (cart.status != PROCESSING || cart.active? == false)
    return true if (item.kind == MEMBERSHIP && !item.item_reservation.present?)
    unprocessed = false
    if (item.item_reservation.present? && item.item_reservation.state == ::Reservation::INSTALMENT &&  item.acquirable.price > 0)
      unprocessed = (AmountOwedForReservation.new(item.item_reservation).amount_owed == item.acquirable.price)
    end
    unprocessed
  end

  def unprocessed_reservation_item?(cart, item)
    CartItemsHelper.unprocessed_reservation_item?(cart, item)
  end

  def self.mark_failed_cart_paid?(cart)
    return false if cart.status != PROCESSING
    return false if cart.cart_items.empty?
    mark_paid = true
    cart.cart_items.each do |i|
      if i.item_reservation.present?
        mark_paid = false if (i.item_reservation.state == INSTALLMENT) && (AmountOwedForReservation.new(i.item_reservation).amount_owed) > 0
      end
    end
    mark_paid
  end

  def mark_failed_cart_paid?(cart)
    CartItemsHelper.mark_failed_cart_paid?(cart)
  end

  def self.mark_failed_cart_inactive?(cart)
    cart.reload
    return false if cart.status != PROCESSING
    return true if cart.cart_items.empty?
  end

  def mark_failed_cart_inactive?(cart)
    CartItemsHelper.mark_failed_cart_inactive?(cart)
  end

  def self.locate_all_cart_item_reservations(cart)
    res_ary = []
    if !cart.cart_items.empty?
      cart.cart_items.each do |i|
        res_ary << i.item_reservation if i.item_reservation
      end
    end
    res_ary
  end

  def locate_all_cart_item_reservations(cart)
    CartItemsHelper.locate_cart_item_reservations(cart)
  end

  def self.now_items_include_only_memberships?(cart)
    CartItem.where({cart: cart, later: false}).where.not(kind: CartItem::MEMBERSHIP).count == 0
  end

  def now_items_include_only_memberships?(cart)
    CartItemsHelper.now_items_include_only_memberships?(cart)
  end

  def self.mark_cart_items_processed(cart, now_items_only = false)
    cart.reload
    cart.cart_items.each do |i|
      i.processed = true if (!i.later || !now_items_only)
      i.save!
    end
  end

  def mark_cart_items_processed(cart, now_items_only = false)
    CartItemsHelper.mark_cart_items_processed(cart, now_items_only)
  end

  def self.stamp_cart_inactive(cart)
    cart.active_to = Time.now
    cart.save!
    cart.reload
  end

  def stamp_cart_inactive(cart)
    CartItemsHelper.stamp_cart_inactive(cart)
  end

  def self.post_payment_housekeeping(cart, now_items_only = false)
    cart.reload
    mark_cart_items_processed(cart, now_items_only)
    stamp_cart_inactive(cart)
  end

  def post_payment_housekeeping(cart, now_items_only = false)
    CartItemsHelper.post_payment_housekeeping(cart, now_items_only)
  end
end
