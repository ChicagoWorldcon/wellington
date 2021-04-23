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
  attr_accessor :now_bin, :later_bin

  AVAILABILITY = "availability"
  PAYMENT_READY = "payment_ready"

  NOW_BIN = "now_bin"
  LATER_BIN = "later_bin"
  BIN_FOR_PURCHASES = NOW_BIN

  def initialize(now_bin: nil, later_bin: nil)
    @now_bin = now_bin
    @later_bin = later_bin
  end

  def full_reload
    @now_bin.reload if @now_bin.present?
    @later_bin.reload if @later_bin.present?
    return
  end

  def now_items
    (@now_bin.present? && @now_bin.cart_items.present?) ? @now_bin.cart_items.to_ary : []
  end

  def later_items
    (@later_bin.present? && @later_bin.cart_items.present?) ? @later_bin.cart_items.to_ary : []
  end

  def user
    if @now_bin && @now_bin.user
      return @now_bin.user
    elsif
      @later_bin && @later_bin.user
      return @later_bin.user
    end
  end

  def purchase_bin
    bin_chooser(BIN_FOR_PURCHASES)
  end

  def purchase_bin_items_paid?
    purchase_bin.items_paid? if purchase_bin.present?
  end

  def purchase_subtotal
    purchase_bin.subtotal_display if purchase_bin.present?
  end

  def purchase_subtotal_cents
    purchase_bin.subtotal_cents if purchase_bin.present?
  end

  def items_to_purchase_count
    purchase_bin.cart_items.count if purchase_bin.present?
  end

  def blank_out_purchase_bin
    case BIN_FOR_PURCHASES
    when NOW_BIN
      @now_bin = nil
    when LATER_BIN
      @later_bin = nil
    end
  end

  def move_item_to_saved(our_item)
    self.move_specific_cart_item(item: our_item, moving_to_saved: true)
  end

  def move_item_to_cart(our_item)
    self.move_specific_cart_item(item: our_item, moving_to_saved: false)
  end

  def save_all_items_for_later
    move_entire_bin_contents(moving_to_saved: true)
  end

  def move_all_saved_to_cart
    move_entire_bin_contents(moving_to_saved: false)
  end

  def destroy_all_items_for_now
    lingering = destroy_specific_bin_contents(now_bin: true)
    lingering == 0
  end

  def destroy_all_items_for_later
    lingering = destroy_specific_bin_contents(now_bin: false)
    lingering == 0
  end

  def destroy_all_cart_contents
    lingering_n = destroy_specific_bin_contents(now_bin: true)
    lingering_l = destroy_specific_bin_contents(now_bin: false)
    lingering = lingering_n.nil? ? 0 : lingering_n
    lingering += lingering_l.nil? ? 0 : lingering_l
    lingering == 0
  end

  def now_items_count
    @now_bin.present? && @now_bin.cart_items.present? ? @now_bin.cart_items.count : 0
  end

  def later_items_count
    @later_bin.present? && @later_bin.cart_items.present? ? @later_bin.cart_items.count : 0
  end

  def all_items_count
    self.now_items_count + self.later_items_count
  end

  def verify_avail_for_items_for_now
    verify_availability_of_bin_contents(now_bin: true)
  end

  def verify_avail_for_saved_items
    verify_availability_of_bin_contents(now_bin: false)
  end

  def verify_avail_for_all_items

    no_now_items = @now_bin.blank? || now_items_count == 0
    no_later_items = @later_bin.blank? || later_items_count == 0
    return {verified: false, problem_items: []} if (no_now_items && no_later_items)

    ver_result = {}
    if no_now_items
      ver_result =  verify_availability_of_bin_contents(now_bin: false)
    elsif no_later_items
      ver_result = verify_availability_of_bin_contents(now_bin: true)
    else
      now_result = verify_availability_of_bin_contents(now_bin: true)
      later_result = verify_availability_of_bin_contents(now_bin: false)
      ver_result[:verified] = now_result[:verified] && later_result[:verified]
      ver_result[:problem_items] = now_result[:problem_items].concat(later_result[:problem_items])
    end

    ver_result
  end

  def can_proceed_to_payment?
    verify_bin_ready_for_payment
  end

  def payment_by_check_allowed?
    # Placeholder-- there may be policies or practicalities
    # that we need to encode.
    true
  end

  private

  def all_bins_present?
    @now_bin.present? && @later_bin.present?
  end

  def supply_any_bin_missing
    @now_bin ||= supply_missing_bin(NOW_BIN)
    @later_bin ||= supply_missing_bin(LATER_BIN)
  end

  def verify_availability_of_bin_contents(now_bin:)
    bin_verifier(now_bin: now_bin, verification: AVAILABILITY)
  end

  def verify_bin_ready_for_payment
    bin_verifier(now_bin: purchase_bin == @now_bin, verification: PAYMENT_READY)
  end

  def bin_verifier(now_bin:, verification: )
    #TODO: Move this to Cart.  It makes more sense there, OO-wise
    target_bin = now_bin ? @now_bin : @later_bin

    return {verified: false, problem_items: []} unless target_bin.present? && target_bin.cart_items.present?


    case verification
    when AVAILABILITY
      v_lambda = -> (item) { item.item_still_available? }
    when PAYMENT_READY
      v_lambda = -> (item) { item.item_ready_for_payment? }
    end

    prob_items = []
    target_bin.cart_items.each do |i|
      if !v_lambda.call(i)
        prob_items << i.quick_description
      end
    end

    {verified: prob_items.blank?, problem_items: prob_items
    }
  end

  def move_entire_bin_contents(moving_to_saved:)
    supply_any_bin_missing
    return -1 unless all_bins_present?
    target_bin = moving_to_saved ? @later_bin : @now_bin
    origin_bin = moving_to_saved ? @now_bin : @later_bin

    return 0 unless origin_bin.cart_items.present?
    moved = 0
    origin_bin.cart_items.each do |i|
      i.cart = target_bin
      i.save
      moved += 1
    end

    self.full_reload
    return moved
  end

  def move_specific_cart_item(item:, moving_to_saved:)
    supply_any_bin_missing
    return unless all_bins_present?
    return unless confirm_original_chassis_for_item(item)
    destination_bin = moving_to_saved ? @later_bin : @now_bin
    item.cart = destination_bin
    item.save
    self.full_reload
    item.cart == destination_bin
  end

  def destroy_specific_bin_contents(now_bin: true)
    target_bin = now_bin ? @now_bin : @later_bin
    return -1 unless target_bin.present?
    return 0 if target_bin.cart_items.blank?
    target_bin.cart_items.each {|i| i.destroy}
    target_bin.reload
    target_bin.cart_items.count
  end

  def locate_specific_cart_item(user:, item_id:)
    locator = CartItemLocator.new(our_user: user, our_item_id: item_id)
    locator.locate_current_cart_item_for_user
  end

  def confirm_original_chassis_for_item(item)
    now_bin_item = (item.cart == @now_bin ? true : false )
    later_bin_item = (item.cart == @later_bin ? true : false )
    now_bin_item || later_bin_item
  end

  def bin_chooser(choice_str)
    chooser = {
      NOW_BIN => @now_bin,
      LATER_BIN => @later_bin
    }

    chooser[choice_str]
  end

  def status_chooser(choice_str)
    chooser = {
      NOW_BIN => Cart::FOR_NOW,
      LATER_BIN => Cart::FOR_LATER
    }

    chooser[choice_str]
  end

  def supply_missing_bin(missing_bin_str)
    missing_bin = nil
    if bin_chooser(missing_bin_str).nil? && self.user.present?
      missing_bin_status = status_chooser(missing_bin_str)
      missing_bin = Cart.active.find_by(user: self.user, status: missing_bin_status)
      unless missing_bin.present? && missing_bin.kind_of?(Cart)
        missing_bin = Cart.create(status: missing_bin_status, user: self.user)
      end
    end
    missing_bin
  end
end
