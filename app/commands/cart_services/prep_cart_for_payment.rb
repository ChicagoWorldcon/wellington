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
  # PENDING = Cart::PENDING
  # PROCESSING = Cart::PROCESSING
  # CHASSIS = "chassis"
  # VANILLA_CART = "vanilla_cart"

  attr_reader :our_cart, :amount_to_charge, :good_to_go, :processing_cart

  def initialize(cart_obj)
    @original_cart_object = cart_obj
    @transaction_bin = identify_transaction_bin(cart_obj)
    @user = note_user(cart_obj)
    @amount_to_charge = 0
    @good_to_go = false
    @initial_item_count = initial_purchasable_item_count(cart_obj)
    #@processing_cart = get_processing_cart
  end

  def call
    prep_cart_items
    if confirm_all_items_prepped
      @good_to_go = true
    else
      @amount_to_charge = 0
    end
    {good_to_go: @good_to_go, amount_to_charge: @amount_to_charge}
  end

  private

  def identify_transaction_bin(cart_o)
    cart_o.now_bin
  end

  def note_user(cart_o)
    cart_o.now_bin.user
  end

  def initial_purchasable_item_count(cart_o)
    cart_o.now_bin.cart_items.count
    #CartItemsHelper.locate_all_membership_items_for_now(@our_cart).count
  end

  # def get_processing_cart
  #   return @processing_cart if @processing_cart
  #   if @cart_type == VANILLA_CART
  #     our_p_cart ||=  Cart.new(
  #       status: PROCESSING,
  #        user: @user,
  #       active_from: Time.now
  #     )
  #     our_p_cart.save!
  #     return our_p_cart
  #   elsif @cart_type == CHASSIS
  #     @our_cart.status == PROCESSING
  #     @our_cart.save!
  #     @original_cart_object.now_cart = Cart.new(
  #       status: PROCESSING,
  #        user: @user,
  #       active_from: Time.now
  #     )
  #     return @our_cart
  #   end
  # end


  def prep_cart_items
    @transaction_bin.reload

    return if @transaction_bin.cart_items.blank?

    ActiveRecord::Base.transaction(joinable: false, requires_new: true)  do
      @transaction_bin.cart_items.each do |item|
        prep_membership_item(item)
      end
    end
  end

  def prep_membership_item(cart_item)
    return if cart_item.kind != MEMBERSHIP
    new_res = cart_item.item_reservation
    new_res ||= CreateReservationFromCartItem.new(cart_item, @user).call
    if new_res.save!
      cart_item.holdable = new_res
      cart_item.cart = @transaction_bin
      @amount_to_charge += AmountOwedForReservation.new(cart_item.item_reservation).amount_owed if cart_item.save!
        #@amount_to_charge += AmountOwedForReservation.new(cart_item.item_reservation).amount_owed
    end
  end

  def confirm_all_items_prepped
    @transaction_bin.reload
    prepped = @transaction_bin.cart_items.reduce(0) { |h_tally, i | h_tally += 1 if i.holdable.present? }
    prepped == @initial_item_count
  end
end
