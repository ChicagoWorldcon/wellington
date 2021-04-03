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

# CartItemLocator does what it says  on the tin: It's a
# repository for the various queries needed to find and process items
# within the Cart
class CartItemLocator
  include ActiveModel::Model

  MEMBERSHIP = CartItem::MEMBERSHIP
  RESERVATION = "Reservation"

  attr_accessor :our_user

  def initalize(our_user: curr_user, item_id: nil)
    @our_user = curr_user
    @our_item_id = item_id
  end

  def locate_current_cart_item_for_user
    #Checks the user and the carts so as to prevent shenanigans
    r_item = CartItem.find_by(id: @our_item_id, user: @our_user)
    return nil if r_item.blank?
    (r_item.cart == our_now_cart || r_item.cart == our_later_cart) ? r_item : nil
  end

  def cart_items_for_now
    n_cart = our_now_cart
    (n_cart.present? && n_cart.cart_items.present?) ? n_cart.cart_items : []
  end

  def cart_items_for_later
    l_cart = our_later_cart
    (l_cart.present? && l_cart.cart_items.present?) ? l_cart.cart_items : []
  end

  def all_current_cart_items(as_ary: true)
    now_c = our_now_cart
    later_c = our_later_cart
    return [] unless (our_now_cart.present? || our_later_cart.present?)
    currs = CartItems.where(cart: now_c).or(CartItems.where(cart: later_c))
    as_ary ? currs.to_ary : currs
  end

  def all_membership_items_for_now(as_ary: true)
    m_items = CartItem.where(cart: our_now_cart, kind: MEMBERSHIP)
    as_ary ? m_items.to_ary : m_items
  end

  def all_membership_items(as_array: true)
    all_ms = all_membership_items_for_now(as_ary: false).or(CartItem.where(cart: our_later_cart, kind: MEMBERSHIP))
    as_array ? all_ms.to_ary : all_ms
  end

  def all_reservations_from_cart_items_for_now
    CartItem.where(cart: our_now_cart, holdable_type: RESERVATION).select('holdable').map(&:holdable)
  end

  def all_reservations_from_cart_items_for_later
    CartItem.where(cart: our_later_cart, holdable_type: RESERVATION).select('holdable').map(&:holdable)
  end

  def all_reservations_from_current_cart_items
    all_reservations_from_cart_items_for_now.concat(all_reservations_from_cart_items_for_later)
  end

  def all_items_for_now_are_memberships?
    CartItem.where({cart: @now_cart, later: false}).where.not(kind: MEMBERSHIP).count == 0
  end

  private

  def our_now_cart
    Cart.active_for_now.find_by(user: @our_user)
  end

  def our_later_cart
    Cart.active_for_later.find_by(user: @our_user)
  end
end
