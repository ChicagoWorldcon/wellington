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

# class CartPaymentStatusValidator < ActiveModel::Validator
#   def validate(record)
#     case record.status
#     when Cart::FOR_NOW
#       # some stuff happens
#       return
#       # Maybe there should be an error if the cart is fully paid?
#       # I don't know.  That's a lot for a model validator to do.
#     when Cart::FOR_LATER
#       if record.charges.present?
#         record.errors.add(:status, :cart_with_charges_cant_be_later_bin, message: "A cart that has recieved charges can't be the bin for later")
#
#     when Cart::AWAITING_CHEQUE
#
#       # some stuff happens
#       record.errors.add(:status, :sucky_status, message: "")
#
#       if record.cart_items.blank?
#         record.errors.add(:status, :an_empty_cart_cannot_recieve_payment, message: "You cannot mark this cart as 'awaiting_cheque' because there is nothing here to pay for.")
#       end
#
#     when Cart::PAID
#       if record.cart_items.blank?
#         record.errors.add(:status, :an_empty_cart_cannot_recieve_payment, message: "")
#       end
#
#     else
#       record.errors.add(:status, :unrecognized_status, message: "#{record.status} is not a recognized status for a #{record.class}")
#     end
#   end
end
