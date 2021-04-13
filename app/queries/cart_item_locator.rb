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
  MEMBERSHIP = CartItem::MEMBERSHIP
  RESERVATION = "Reservation"

  attr_accessor :our_user, :our_item_id

  def initialize(our_user: curr_user, our_item_id: nil)
    @our_user = our_user
    @our_item_id = our_item_id
  end

  def locate_current_cart_item_for_user
    #Checks the carts (and also thereby checks the user) so as to prevent shenanigans
    r_item = CartItem.where(cart: [our_now_bin, our_later_bin], id: @our_item_id)
    r_item.length == 1 ? r_item[0] : nil
  end

  def cart_items_for_now
    n_bin = our_now_bin
    (n_bin.present? && n_bin.cart_items.present?) ? n_bin.cart_items : []
  end

  def cart_items_for_later
    l_bin = our_later_bin
    (l_bin.present? && l_bin.cart_items.present?) ? l_bin.cart_items : []
  end

  def all_current_cart_items(as_ary: true)
    currs = CartItem.where(cart: [our_now_bin, our_later_bin])
    as_ary ? currs.to_ary : currs
  end

  def all_membership_items_for_now(as_ary: true)
    m_items = CartItem.where(cart: our_now_bin, kind: MEMBERSHIP)
    as_ary ? m_items.to_ary : m_items
  end

  def all_membership_items(as_array: true)
    all_ms = CartItem.where(cart: [our_now_bin, our_later_bin], kind: MEMBERSHIP)
    as_array ? all_ms.to_ary : all_ms
  end

  def all_reservations_from_cart_items_for_now
    CartItem.where(cart: our_now_bin, holdable_type: RESERVATION).select('holdable').map(&:holdable)
  end

  def all_reservations_from_cart_items_for_later
    CartItem.where(cart: our_later_bin, holdable_type: RESERVATION).select('holdable').map(&:holdable)
  end

  def all_reservations_from_current_cart_items
    # all_reservations_from_cart_items_for_now.concat(all_reservations_from_cart_items_for_later)
    CartItem.where(cart: [our_now_bin, our_later_bin], holdable_type: RESERVATION).select('holdable').map(&:holdable)
  end

  def all_items_for_now_are_memberships?
    CartItem.where({cart: our_now_bin, later: false}).where.not(kind: MEMBERSHIP).count == 0
  end

  private

  def our_now_bin
    Cart.active_for_now.find_by(user: @our_user)
  end

  def our_later_bin
    Cart.active_for_later.find_by(user: @our_user)
  end
end
