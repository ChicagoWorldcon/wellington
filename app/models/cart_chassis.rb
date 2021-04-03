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

# A CartChassis is a Plain Old Ruby Object (with no presence of its own
# in the database) that consists of two carts (each of which DOES have a
# a presence in the database).  One cart, with the status for_now, contains
# the user's current items.  The other cart, with the status for_later,
# contains items the user isn't ready to purchase yet.

# When the user is ready to pay (or to reserve, pending payment by cheque)
# the user's for_now cart goes into processing and gets a new status, and a new,
# empty for_now cart is generated.

# The CartChassis exists just to make things a bit tidier in the controllers
# and views.  It doesn't (and shouldn't!) contain any unique info of its own.

class CartChassis
  include ActiveModel::Model
  attr_accessor :now_cart, :later_cart

  def initialize(now_cart: nil, later_cart: nil)
    @now_cart = now_cart
    @later_cart = later_cart
  end

  def self.full_reload
    @now_cart.reload if @now_cart.present?
    @later_cart.reload if @later_cart.present?
  end

  def self.save_all_items_for_later
    return -1 unless @now_cart && @later_cart
    @now_cart.cart_items.each do |i|
      i.later = true
      i.cart = @later_cart
      i.save
    end
    self.full_reload
    return @now_cart.cart_items.count
  end

  def self.move_all_saved_to_cart
    return -1 unless @now_cart && @later_cart
    @later_cart.cart_items.each do |i|
      i.later = false
      i.cart = @now_cart
      i.save
    end
    self.full_reload
    return @later_cart.cart_items.count
  end

  def self.destroy_all_items_for_now
    return unless @now_cart
    return 0 if @now_cart.cart_items.blank?
    @now_cart.cart_items.each {|i| i.destroy}
    @now_cart.reload
    @now_cart.cart_items.count
  end

  def self.destroy_all_items_for_later
    return unless @later_cart
    return 0 if @later_cart.cart_items.blank?
    @later_cart.cart_items.each {|i| i.destroy}
    @later_cart.reload
    @later_cart.cart_items.count
  end

  def self.destroy_all_cart_contents
    lingering_n = self.destroy_all_items_for_now
    lingering_l = self.destroy_all_items_for_later
    lingering_n + lingering_l
  end

  def self.now_items_count
    @now_cart.present? && @now_cart.cart_items.present? ? @now_cart.cart_items.count : 0
  end

  def self.later_items_count
    @later_cart.present? && @later_cart.cart_items.present? ? @later_cart.cart_items.count : 0
  end

  def self.all_items_count
    self.now_items_count + self.later_items_count
  end

  def self.can_proceed_to_payment?
    return false if (@now_cart.blank? || @now_cart.cart_items.size == 0)
    all_ready = true
    @now_cart.cart_items.each {|i| all_ready = false if !i.item_ready_for_payment}
    all_ready
  end
end
