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
#
class CentsOwedForCartContents
  attr_reader :cart

  def initialize(cart)
    @cart = cart
    @total_owed_for_cart_items = accumulate_cart_item_amounts_owing(cart)
    @total_successful_cart_charges = total_paid_for_cart(cart)
  end

  def owed_cents
    @total_owed_for_cart_items - @total_successful_cart_charges
  end

  private

  def accumulate_cart_item_amounts_owing(cart)
    cart.cart_items.inject(0){|a, i| } i + amount_owed_for_cart_item(i)
  end

  def amount_owed_for_cart_item(item)
    return 0 if !item.price_cents
    item.price_cents - item.charges.successful.sum(:amount_cents)
  end

  def total_paid_for_cart(cart)
    cart.charges.successful.sum(:amount_cents)
  end
end
