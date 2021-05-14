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


class CartServices::CreateReservationFromCartItem
  attr_reader :cart_item, :customer

  def initialize(cart_item, customer)
    @cart_item = cart_item
    @customer = customer
  end

  def call
    unless @cart_item.acquirable.kind_of?(Membership)
      raise TypeError.new "Expected a membership cart item, got a #{@cart_item.acquirable.class} item." and return
    end

    unless @cart_item.item_ready_for_payment?
      raise StandardError.new "CartItem #{@cart_item.id} cannot be purchased at this time"
    end

    new_reservation = ActiveRecord::Base.transaction(joinable: false, requires_new: true) do

      service = ClaimMembership.new(@cart_item.acquirable, customer: @customer)
      our_reservation = service.call
      @cart_item.benefitable.claim = our_reservation.active_claim
      @cart_item.benefitable.save!
      @cart_item.reload

      our_reservation
    end
    new_reservation
  end
end
