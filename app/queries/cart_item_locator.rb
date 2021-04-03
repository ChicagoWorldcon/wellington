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
# repository for the various queries needed to find and proces items
# within the Cart
class CartItemLocator
  include ActiveModel::Model

  attr_reader :target_item
  attr_reader :target_item_ary
  attr_accessor :our_user
  attr_accessor :our_item_id
  attr_accessor :our_now_cart
  attr_accessor :our_later_cart

  def initalize(our_user: curr_user, item_id: nil)
    @our_user = curr_user
    @our_now_cart = Cart.active_for_now.find_by(user: curr_user)
    @our_later_cart = Cart.active_for_later.find_by(user: curr_user)
    @our_item_id = item_id
  end

  def locate_cart_item_for_user
    r_item = CartItem.find_by(id: our_item_id)
    # TODO: See if u_item works, and also if we need an explicit return below.
    # u_item = CartItem.find_by(id: our_item_id, user: @our_user)
    (r_item.present? && r_item.user == @our_user) ? r_item : nil
  end

  def cart_items_for_now
    n_cart = our_now_cart
    (n_cart.present? && n_cart.cart_items.present?) ? n_cart.cart_items : []
  end

  def cart_items_for_later
    l_cart = our_later_cart
    (l_cart.present? && l_cart.cart_items.present?) ? l_cart.cart_items : []
  end

  private

  def our_now_cart
    Cart.active_for_now.find_by(user: @our_user)
  end

  def our_later_cart
    Cart.active_for_later.find_by(user: @our_user)
  end
end
