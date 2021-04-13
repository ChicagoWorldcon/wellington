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

  def initialize(now_bin: nil, later_bin: nil)
    @now_bin = now_bin
    @later_bin = later_bin
  end

  def full_reload
    @now_bin.reload if @now_bin.present?
    @later_bin.reload if @later_bin.present?
  end

  def now_items
    (@now_bin.present? && @now_bin.cart_items.present?) ? @now_bin.cart_items : []
  end

  def later_items
    (@later_bin.present? && @later_bin.cart_items.present?) ? @later_bin.cart_items : []
  end

  # def has_now_items?
  #   @now_bin.present? && @now_bin.cart_items.present?
  # end
  #
  # def has_later_items?
  #   @later_bin.present? && @later_bin.cart_items.present?
  # end

  def purchase_subtotal
    @now_bin.subtotal_display
  end

  def move_item_to_saved(our_item)
    self.move_specific_cart_item(item: our_item, moving_to_saved: true)
  end

  def move_item_to_cart(our_item)
    binding.pry
    self.move_specific_cart_item(item: our_item, moving_to_saved: false)
  end

  def save_all_items_for_later
    binding.pry
    move_entire_bin_contents(moving_to_saved: true)
  end

  def move_all_saved_to_cart
    binding.pry
    move_entire_bin_contents(moving_to_saved: false)
    # return -1 unless @now_bin && @later_bin
    # @later_bin.cart_items.each do |i|
    #   i.later = false
    #   i.cart = @now_bin
    #   i.save
    # end
    # self.full_reload
    # return @later_bin.cart_items.count
  end

  # def destroy_specific_item(target_item_id:, user:)
  #   destroy_specific_cart_item(item_id: target_item_id, user: user)
  # end

  def destroy_all_items_for_now
    binding.pry
    lingering = destroy_specific_bin_contents(now_bin: true)
    binding.pry
    lingering == 0
  end

  def destroy_all_items_for_later
    binding.pry
    lingering = destroy_specific_bin_contents(now_bin: false)
    binding.pry
    lingering == 0
  end

  def destroy_all_cart_contents
    binding.pry
    lingering_n = destroy_specific_bin_contents(now_bin: true)
    lingering_l = destroy_specific_bin_contents(now_bin: false)
    binding.pry
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
    now_avail = verify_availability_of_bin_contents(now_bin: true)
    later_avail = verify_availability_of_bin_contents(now_bin: false)
    {
      verified: now_avail[:verified] && later_avail[:verified],
      problem_items: now_avail[:problem_items].concat(later_avail[:problem_items])
    }
  end

  def can_proceed_to_payment?
    # return false if (@now_cart.blank? || @now_bin.cart_items.size == 0)
    # all_ready = true
    # @now_bin.cart_items.each {|i| all_ready = false if !i.item_ready_for_payment?}
    # all_ready
    verify_bin_ready_for_payment
  end

  def payment_by_check_allowed?
    true
  end

  private
  def all_bins_present?
    @now_bin.present? && @later_bin.present?
  end

  def verify_availability_of_bin_contents(now_bin:)
    # target_bin = now_bin ? @now_bin : @later_bin
    # return unless target_bin && target_bin.cart_items.present?
    # prob_items = []
    # target_bin.cart_items.each do |item|
    #   if !item.item_ready_for_payment?
    #     prob_items << "#{item.quick_description}, "
    #   end
    # end
    # prob_items

    bin_verifier(now_bin: now_bin, verification: AVAILABILITY)
  end

  def verify_bin_ready_for_payment
    # target_bin = now_bin ? @now_bin : @later_bin
    # return false unless target_bin && target_bin.cart_items.present?
    # prob_items = []
    # target_bin.cart_items.each do |item|
    #   if !item.item_still_available?
    #     prob_items << "#{item.quick_description}, "
    #   end
    # end
    # prob_items
    bin_verifier(now_bin: true, verification: PAYMENT_READY)
  end

  def bin_verifier(now_bin:, verification: )
    target_bin = now_bin ? @now_bin : @later_bin

    case verification
    when AVAILABILITY
      return {verified: true, problem_items: []} unless target_bin && target_bin.cart_items.present?
      v_lambda = -> (item) { item.item_still_available? }
    when PAYMENT_READY
      return {verified: false, problem_items: []} unless target_bin && target_bin.cart_items.present?
      v_lambda = -> (item) { item.item_ready_for_payment? }
    end

    prob_items = []
    target_bin.cart_items.each do |i|
      prob_items << i.quick_description if !v_lambda.call(i)
    end
    {verified: prob_items.blank?, problem_items: prob_items}
  end

  def move_entire_bin_contents(moving_to_saved:)
    binding.pry
    return -1 unless all_bins_present?

    target_bin = moving_to_saved ? @later_bin : @now_bin
    origin_bin = moving_to_saved ? @now_bin : @later_bin

    return 0 unless origin_bin.cart_items.present?
    binding.pry
    origin_bin.cart_items.each do |i|
      i.cart = target_bin
      i.later = (i.cart == @later_bin) ? true : false
      i.save
    end

    self.full_reload
    binding.pry
    return origin_bin.cart_items.count
  end

  def move_specific_cart_item(item:, moving_to_saved:)
    return unless all_bins_present?
    binding.pry
    destination_bin = moving_to_saved ? @later_bin : @now_bin
    item.cart = destination_bin
    item.later = (item.cart == @later_bin) ? true : false
    item.save
    item.cart == destination_bin
  end

  # def destroy_specific_cart_item(item_id:, user: )
  #   target_item = locate_specific_cart_item(user: user, item_id: item_id)
  #   return unless target_item
  #   ex_kind = target_item.kind
  #   ex_name = target_item.item_display_name
  #   destroyed = target_item.destroy
  #   return {item_kind: ex_kind, item_name: ex_name, destroyed_ok: destroyed}
  # end

  def destroy_specific_bin_contents(now_bin: true)
    binding.pry
    target_bin = now_bin ? @now_bin : @later_bin
    return unless target_bin.present?
    return 0 if target_bin.cart_items.blank?
    target_bin.cart_items.each {|i| i.destroy}
    binding.pry
    target_bin.reload
    target_bin.cart_items.count
  end

  def locate_specific_cart_item(user:, item_id:)
    locator = CartItemLocator.new(our_user: user, our_item_id: item_id)
    locator.locate_current_cart_item_for_user
  end
end
