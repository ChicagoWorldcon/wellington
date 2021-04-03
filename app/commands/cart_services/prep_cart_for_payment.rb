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

class CartServices::PrepCartForPayment

  MEMBERSHIP = CartItem::MEMBERSHIP
  PENDING = Cart::PENDING
  PROCESSING = Cart::PROCESSING
  CHASSIS = "chassis"
  VANILLA_CART = "vanilla_cart"

  attr_reader :our_cart, :amount_to_charge, :good_to_go, :processing_cart

  def initialize(cart_obj)
    @original_cart_object = cart_obj
    @our_cart = figure_out_cart(cart_obj)
    @cart_type = note_cart_type(cart_obj)
    @user = note_user(cart_obj)
    @amount_to_charge = 0
    @good_to_go = false
    @initial_item_count = initial_purchasable_item_count
    @processing_cart = get_processing_cart
  end

  def call
    prep_cart_items
    if confirm_all_items_prepped
      @good_to_go = true
    else
      @amount_to_charge = 0
    end
    return {good_to_go: @good_to_go, amount_to_charge: @amount_to_charge, processing_cart: @processing_cart}
  end

  private

  def figure_out_cart(cart_o)
    case
    when cart_o.kind_of?(Cart)
      return cart_o
    when cart_o.kind_of?(CartChassis)
      return cart_o.now_cart
    end
  end

  def note_cart_type(cart_o)
    case
    when cart_o.kind_of?(Cart)
      return VANILLA_CART
    when cart_o.kind_of?(CartChassis)
      return CHASSIS
    end
  end

  def note_user(cart_o)
    case
    when cart_o.kind_of?(Cart)
      return cart_o.user
    when cart_o.kind_of?(CartChassis)
      return cart_o.now_cart.user
    end
  end

  def initial_purchasable_item_count
    CartItemsHelper.locate_all_membership_items_for_now(@our_cart).count
  end

  def get_processing_cart
    return @processing_cart if @processing_cart
    if @cart_type == VANILLA_CART
      our_p_cart ||=  Cart.new(
        status: PROCESSING,
         user: @user,
        active_from: Time.now
      )
      our_p_cart.save!
      return our_p_cart
    elsif @cart_type == CHASSIS
      @our_cart.status == PROCESSING
      @our_cart.save!
      @original_cart_object.now_cart = Cart.new(
        status: PROCESSING,
         user: @user,
        active_from: Time.now
      )
      return @our_cart
    end
  end


  def prep_cart_items
    @our_cart.reload
    @processing_cart.reload

    items_to_buy = CartItemsHelper.cart_items_for_now(@our_cart)
    return if items_to_buy.empty?

    ActiveRecord::Base.transaction(joinable: false, requires_new: true)  do
      items_to_buy.each do |item|
        prep_membership_item(item)
      end
    end

    @processing_cart.reload
    @our_cart.reload
  end

  def prep_membership_item(cart_item)
    return if cart_item.kind != MEMBERSHIP
    new_res = cart_item.item_reservation
    new_res ||= CreateReservationFromCartItem.new(cart_item, @user).call
    if new_res.save!
      cart_item.holdable = new_res
      cart_item.cart = (@cart_type == VANILLA_CART) ? @processing_cart : cart_item.cart
      if cart_item.save!
        @amount_to_charge += AmountOwedForReservation.new(cart_item.item_reservation).amount_owed
      end
    end
  end

  def confirm_all_items_prepped
    @our_cart.reload
    case @cart_type
    when VANILLA_CART
      return @processing_cart.cart_items.count == @initial_item_count
    when CHASSIS
      holdable_count = 0
      @our_cart.cart_items.each {|i| holdable_count++ if i.holdable.present?}
      return holdable_count == @initial_item_count
    end
  end
end
