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

#NOTES ON WHAT'S HAPPENING HERE:

 # (1) pay_for_cart_items() is preparing the thing that's going to
 #     be fed into the ChargesController's cart-specific New action.
 #     (It might be that we'll need to add something extra to Cart
 #     to hold all of tihs, though that's not my preference.)
 #
 # (2) ChargesController#new_cart_group will feed the payment form
 #     for which we've already made a preliminary view (new_cart_group.erb).
 #     That will feed to a cart-specific Create method (TODO) that will
 #     Run the Money::ChargeCustomer command.
 #
 #     (a) In order to run Money::ChargeCustomer, we have to get the
 #         polymorphic association (buyable) in place for Charge.
 #
 #         The module is made, and includes an explanation, we just need
 #         to:
 #         *   Make the necessary model changes
 #         *   Do the migration (it's drafted, and the draft is in Notes)]

class PrepCartForPayment

  MEMBERSHIP = "membership"

  def initialize(cart)
    @our_cart = cart
    @items_count = @our_cart.cart_items.count
    @failed = []
    @ready_for_charge = {
      reservations: []
    }
    @cents_to_charge = 0
  end

  def call
    prep_membership_items
    confirm_all_items_prepped
    calc_charge_amount
    #TODO: Make the Stripe call

  end

  private

  def prep_membership_items
    membership_items = @our_cart.locate_all_membership_items
    membership_items.each do |m_item|
      new_res = ReservationsHelper.process_resrv_cart_item(m_item.benefitable, m_item.acquirable)
      if new_res.present?
        @ready_for_charge[:reservations] << new_res
      else
        @failed << m_item
      end
    end
  end

  def confirm_all_items_prepped
    prepped_count = 0
    @ready_for_charge.each do |k, v|
      prepped_count += v.count
    end
    all_prepped = (prepped_count == @items_count)
    no_failures = @failed.empty?
    return all_prepped && no_failures
  end

  def calc_charge_amount(cart)
    our_total = 0
    @ready_for_charge[:reservations].each do |r|
      our_total += AmountOwedForReservation.new(r).amount_owed
    end
    @cents_to_charge = our_total
  end
end
