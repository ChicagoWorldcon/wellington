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

  MEMBERSHIP = "membership"

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

  def self.cart_contents_ready_for_payment?(cart)
    all_contents_ready = true
    cart.cart_items.each {|i| all_contents_ready = false if !i.item_ready_for_payment?}
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
end
