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

class CartServices::WaitForCheckHousekeeping

  attr_reader :our_cart

  def initialize(c_chassis)
    @our_cart_chassis = c_chassis
    @transaction_cart = c_chassis.purchase_bin
    @our_user = c_chassis.user
    @amount_owed = c_chassis.purchase_subtotal_cents
  end

  def call
    trigger_cart_waiting_for_cheque_payment_mailer
    transaction_cart_housekeeping
    cart_chassis_housekeeping
  end

  private

  def transaction_cart_housekeeping
    @transaction_cart.update!(status: Cart::AWAITING_CHEQUE)
    @transaction_cart.update!(active_to: Time.now)
  end

  def cart_chassis_housekeeping
    @our_cart_chassis.now_bin = nil
  end

  def trigger_cart_waiting_for_cheque_payment_mailer
    amt_owed = @amount_owed.kind_of?(Integer) ? @amount_owed : @amount_owed.cents

    item_descs = CartContentsDescription.new(
      @transaction_cart,
      with_layperson_uniq_id: true,
      for_email: true,
      force_full_contact_name: true
    ).describe_cart_contents

    PaymentMailer.cart_waiting_for_cheque(
      user: @our_user,
      item_count: @transaction_cart.cart_items.size,
      outstanding_amount: amt_owed,
      item_descriptions: item_descs,
      transaction_date: Time.now,
      cart_number: @transaction_cart.id
    ).deliver_later
  end
end
