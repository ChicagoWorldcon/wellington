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


class CartServices::AfterPaymentHousekeeping

  attr_reader :transaction_cart

  def initialize(trans_cart)
    @transaction_cart = trans_cart
    @our_user = trans_cart.user
  end

  def call
    transaction_cart_housekeeping
  end

  private

  def transaction_cart_housekeeping
    @transaction_cart.update!(active_to: Time.now)
    @transaction_cart.update!(status: Cart::PAID) if @transaction_cart.subtotal_cents <= 0
  end
end
