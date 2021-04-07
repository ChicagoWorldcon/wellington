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


class CartServices::ResolveCartChassis
  FOR_NOW = Cart::FOR_NOW
  FOR_LATER = Cart::FOR_LATER

  attr_accessor :our_user, :existing_cart_chassis

  def initialize(user: our_user, existing_cart_chassis: nil)
    binding.pry
    @our_user = user
    @curr_c_c = existing_cart_chassis
  end

  def call
    binding.pry
    our_now_bin = locate_chassis_bin(for_later: false)
    our_later_bin = locate_chassis_bin(for_later: true)
    CartChassis.new(now_bin: our_now_bin, later_bin: our_later_bin)
  end

  private

  def locate_chassis_bin(for_later: false)
    binding.pry
    our_bin = nil

    if @curr_c_c.present?
      our_bin = (for_later && @curr_c_c.later_bin.present?) ? @curr_c_c.later_bin : nil
      our_bin ||= (!for_later && @curr_c_c.now_bin.present?) ? @curr_c_c.now_bin : nil
    end

    binding.pry

    our_bin ||= for_later ? Cart.active_for_later.find_by(user: @our_user) : Cart.active_for_now.find_by(user: @our_user)

    binding.pry

    our_bin ||= for_later ? create_cart_bin(with_status: FOR_LATER) : create_cart_bin(with_status: FOR_NOW)

    binding.pry

    our_bin
  end



  def create_cart_bin(with_status:)
    # Status FOR_NOW is for the part of the cart where active items go.
    # Status FOR_LATER is for the part of the cart where saved items go.
    binding.pry
    cart_bin = Cart.new status: with_status
    # current_user is a Devise helper.
    cart_bin.user = @our_user
    cart_bin.active_from = Time.now
    binding.pry
    if cart_bin.save
      binding.pry
      flash[:status] = :success
    else
      binding.pry
      flash[:status] = :failure
      flash[:notice] = "We weren't able to fully create your shopping cart."
      flash[:messages] = cart_bin.errors.messages
    end
    binding.pry
    cart_bin
  end
end
