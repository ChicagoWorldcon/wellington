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

module CartItemsHelper

  MAX_CHARS_FOR_EMAIL_CART_DESCRIPTION = 10000
  MAX_CHARS_FOR_ONSCREEN_CART_DESCRIPTION = 10000

  MEMBERSHIP = "membership"
  PAID = "paid"

  FULL = "full"
  PARTIAL = "partial"
  NONE = "none"
  NO_RESERVATION = "no_reservation"

  # TODO: See if this can be eliminated.  There's a new method
  # in MembershipOffer that should handle this. Currently, all
  # it's doing is getting tested.
  def self.locate_offer(offer_params)
    target_offer = MembershipOffer.options.find do |offer|
      offer.hash == offer_params
    end
    if !target_offer.present?
      flash[:error] = t("errors.offer_unavailable", offer: offerParams)
    end
    target_offer
  end

  def locate_offer(offer_params)
    CartItemsHelper.locate_offer(offer_params)
  end

  def self.reservation_payment_status(c_item)
    return {payment_status: NO_RESERVATION, status_desc: "Not yet reserved."} if !c_item.item_reservation.present?

    owed = AmountOwedForReservation.new(c_item.item_reservation).amount_owed.cents
    payment_recorded = ReservationPaymentHistory.new(c_item.item_reservation).any_successful_charges?

    return {payment_status: FULL, status_desc: "Reserved and paid in full."} if owed <= 0
    return {payment_status: PARTIAL, status_desc: "Reserved and paid in part."} if payment_recorded
    {payment_status: NONE, status_desc: "Reserved but not yet paid"}
  end

  def reservation_payment_status(c_item)
    CartItemsHelper.reservation_payment_status(c_item)
  end

  # def self.locate_cart_item(item_id)
  #   CartItem.find_by(id: item_id)
  # end
  #
  # def locate_cart_item(item_id)
  #   CartItemsHelper.locate_cart_item(item_id)
  # end
  #
  # def self.locate_cart_item_with_cart(item_id, c_object)
  #   binding.pry
  #   CartItem.find_by(id: item_id, cart: c_object)
  # end
  #
  # def locate_cart_item_with_cart(cart_item_id, c_object)
  #   binding.pry
  #   case
  #   when c_object.kind_of?(Cart)
  #     binding.pry
  #     CartItemsHelper.locate_cart_item_with_cart(cart_item_id, c_object)
  #   when c_object.kind_of?(CartChassis)
  #     binding.pry
  #     locator = CartItemLocator.new(our_user: current_user, item_id: cart_item_id)
  #     locator.locate_current_cart_item_for_user
  #   end
  # end

  def self.locate_cart_item(user, cart_item_id)
    locator = CartItemLocator.new(our_user: user, our_item_id: cart_item_id)
    locator.locate_current_cart_item_for_user
  end

  def locate_cart_item(cart_item_id)
    CartItemsHelper.locate_cart_item(cart_item_id)
  end

  # def self.cart_items_for_now(cart)
  #   if cart
  #     cart.cart_items.select {|i| !i.later}
  #   else
  #     return nil
  #   end
  # end

  # def cart_items_for_now(c_object)
  #   case
  #   when c_object.kind_of?(Cart)
  #     CartItemsHelper.cart_items_for_now(c_object)
  #   when c_object.kind_of?(CartChassis)
  #     binding.pry
  #     locator = CartItemLocator.new(our_user: current_user)
  #     binding.pry
  #     locator.cart_items_for_now
  #   end
  # end
  #
  # def self.cart_items_for_later(cart)
  #   if cart.present?
  #     cart.cart_items.select {|i| i.later}
  #   else
  #     return nil
  #   end
  # end
  #
  # def cart_items_for_later(c_object)
  #   case
  #   when c_object.kind_of?(Cart)
  #     CartItemsHelper.cart_items_for_now(c_object)
  #   when c_object.kind_of?(CartChassis)
  #     CartItemLocator.new(our_user: current_user).cart_items_for_later
  #   end
  # end
  #
  # def self.cart_contents_verifier(c_object)
  #   case
  #   when c_object.kind_of?(Cart)
  #     verify_availability_of_cart_contents(c_object)
  #   when c_object.kind_of?(CartChassis)
  #     now_v = verify_availability_of_cart_contents(c_object.now_cart)
  #     later_v = verify_availability_of_cart_contents(c_object.later_cart)
  #     return now_v && later_v
  #   end
  # end
  #
  # def self.verify_availability_of_cart_contents(cart)
  #   if cart.present?
  #     all_contents_available = true;
  #     cart.cart_items.each do |item|
  #       if item.item_still_available? == false
  #         all_contents_available = false
  #       end
  #     end
  #     cart.reload
  #     return all_contents_available
  #   else
  #     return nil
  #   end
  # end
  #
  # def verify_availability_of_cart_contents(cart)
  #   CartItemsHelper.verify_availability_of_cart_contents(cart)
  # end
  #
  # def self.cart_contents_readiness_machine(c_object, for_now_only: false)
  #
  # end
  #
  def self.ready_for_payment?(c_chassis)
    c_chassis.can_proceed_to_payment?
  end

  def ready_for_payment?(c_chassis)
    CartItemsHelper.ready_for_payment?(c_chassis)
  end

  def self.items_with_reservations_present?(cart_bin)
    ReservationsInCart.new(cart_bin).reservations_gathered.present?
  end

  def items_with_reservations_present?(cart_bin)
    CartItemsHelper.items_with_reservations_present?(cart_bin)
  end

  def group_deletion_button(cart_object)
    reservation_warning_needed = false
    confirm_hash = {
      confirm: "At least one membership in your cart has already been reserved. When you delete it from your cart, it will not be cancelled, and you will still be able to review and update it from your Membership Page. Delete anyway?" }

    if cart_object.kind_of?(CartChassis)
      reservation_warning_needed = ReservationsInCart.new(cart_object.now_bin).reservations_gathered.present?
      reservation_warning_needed ||= ReservationsInCart.new(cart_object.later_bin).reservations_gathered.present?
      button_text = "Delete All Cart Contents"
      button_route = cart_empty_path
    else
      reservation_warning_needed = ReservationsInCart.new(cart_object).reservations_gathered.present?
      button_text = (cart_object.status == Cart::FOR_LATER) ? "Delete All Saved Items" : "Delete All Items for Now"
      button_route = (cart_object.status == Cart::FOR_LATER) ? cart_clear_all_saved_path : cart_clear_all_active_path
    end

    data_object = reservation_warning_needed ? confirm_hash : {}
    our_button = button_to(button_text, button_route, method: "delete", data: data_object, class: "btn btn-outline-info")
  end



  # def self.cart_contents_destroyer(c_object)
  #   case
  #   when c_object.kind_of?(Cart)
  #     destroy_cart_contents(c_object)
  #   when c_object.kind_of?(CartChassis)
  #     destroy_cart_contents(c_object.now_cart)
  #     destroy_cart_contents(c_object.later_cart)
  #   end
  # end
  #
  # def self.destroy_cart_contents(cart)
  #   if cart
  #     cart.cart_items.each {|i| i.destroy}
  #     cart.reload
  #     return cart.cart_items.empty?
  #   else
  #     return nil
  #   end
  # end
  #
  # def destroy_cart_contents(cart)
  #   cart.reload
  #   CartItemsHelper.destroy_cart_contents(cart)
  # end

  # def destroy_complete_cart_contents(our_cart)
  #   if cart
  #     nows_gone = destroy_specific_bin_contents(cart: our_cart, now_bin: true)
  #     laters_gone = destroy_specific_bin_contents(cart: our_cart, now_bin: false)
  #     return nows_gone && laters_gone
  #   else
  #     return nil
  #   end
  # end
  #
  # def destroy_cart_items_for_now(our_cart)
  #   if cart
  #     return destroy_specific_bin_contents(cart: our_cart, now_bin: true)
  #   else
  #     return nil
  #   end
  # end
  #
  # def destroy_cart_items_for_later(our_cart)
  #   if cart
  #     return destroy_specific_bin_contents(cart: our_cart, now_bin: false)
  #   else
  #     return nil
  #   end
  # end


  # def self.destroy_for_now_cart_items(cart)
  #   if cart
  #     cart.reload
  #     now_items = cart_items_for_now(cart)
  #     now_items.each {|i| i.destroy}
  #     cart.reload
  #     return cart_items_for_now(cart).empty?
  #   else
  #     return nil
  #   end
  #
  #
  # end

  # def destroy_for_now_cart_items(c_object)
  #   case
  #   when c_object.kind_of?(Cart)
  #     c_object.reload
  #     return CartItemsHelper.destroy_for_now_cart_items(c_object)
  #   when c_object.kind_of?(CartChassis)
  #     c_object.full_reload
  #     return c_object.destroy_all_cart_contents
  #   end
  # end
  #
  # def self.destroy_cart_items_for_later(cart)
  #   if cart
  #     later_items = cart_items_for_later(cart)
  #     later_items.each {|i| i.destroy}
  #     cart.reload
  #     return cart_items_for_later(cart).empty?
  #   end
  # end
  #
  # def destroy_cart_items_for_later(c_object)
  #   case
  #   when c_object.kind_of?(Cart)
  #     c_object.reload
  #     return CartItemsHelper.destroy_cart_items_for_later(c_object)
  #   when c_object.kind_of?(CartChassis)
  #     c_object.full_reload
  #     return c_object.destroy_all_items_for_later
  #   end
  # end

  # def self.save_all_cart_items_for_later(cart)
  #   if cart
  #     cart.cart_items.each do  |i|
  #       i.later = true
  #       i.save
  #     end
  #     cart.reload
  #     return cart_items_for_now(cart).empty?
  #   else
  #     return nil
  #   end
  # end
  #
  # def save_all_cart_items_for_later(c_object)
  #   case
  #   when c_object.kind_of?(Cart)
  #     c_object.reload
  #     return CartItemsHelper.save_all_cart_items_for_later(c_object)
  #   when c_object.kind_of?(CartChassis)
  #     c_object.full_reload
  #     return c_object.save_all_items_for_later
  #   end
  # end
  #
  # def self.unsave_all_cart_items(cart)
  #   if cart
  #     cart.cart_items.each do |i|
  #       i.later = false
  #       unless i.save
  #         flash[:error] = "unable to move #{i.item_display_name} to cart"
  #         flash[:messages] = i.errors.messages
  #         all_movable = false
  #       end
  #     end
  #     cart.reload
  #     return cart_items_for_later(cart).empty?
  #   else
  #     return -1
  #   end
  # end
  #
  # def unsave_all_cart_items(c_object)
  #   case
  #   when c_object.kind_of?(Cart)
  #     c_object.reload
  #     return CartItemsHelper.unsave_all_cart_items(c_object)
  #   when c_object.kind_of?(CartChassis)
  #     c_object.full_reload
  #     return c_object.move_all_saved_to_cart
  #   end
  # end

  # def self.locate_all_membership_items(cart)
  #   if cart.present?
  #     cart.cart_items.select {|i| i.kind == MEMBERSHIP}
  #   else
  #     return nil
  #   end
  # end
  #
  # def locate_all_membership_items(c_object)
  #   case
  #   when c_object.kind_of?(Cart)
  #     c_object.reload
  #     return CartItemsHelper.locate_all_membership_items(c_object)
  #   when c_object.kind_of?(CartChassis)
  #     c_object.full_reload
  #     return c_object.all_membership_items
  #   end
  # end
  #
  # def self.locate_all_membership_items_for_now(cart)
  #   if cart.present?
  #     cart.cart_items.select {|i| i.kind == MEMBERSHIP && i.later == false}
  #   else
  #     return nil
  #   end
  # end
  #
  # def locate_all_membership_items_for_now(c_object)
  #   case
  #   when c_object.kind_of?(Cart)
  #     c_object.reload
  #     return CartItemsHelper.locate_all_membership_items(c_object)
  #   when c_object.kind_of?(CartChassis)
  #     c_object.full_reload
  #     return c_object.all_membership_items_for_now
  #   end
  # end
  #
  # def self.locate_all_cart_item_reservations(cart)
  #   res_ary = []
  #   if !cart.cart_items.empty?
  #     cart.cart_items.each do |i|
  #       res_ary << i.item_reservation if i.item_reservation
  #     end
  #   end
  #   res_ary
  # end
  #
  # def locate_all_cart_item_reservations(c_object)
  #   case
  #   when c_object.kind_of?(Cart)
  #     c_object.reload
  #     return CartItemsHelper.locate_cart_item_reservations(c_object)
  #   when c_object.kind_of?(CartChassis)
  #     c_object.full_reload
  #     return c_object.all_reservations_from_current_cart_items
  #   end
  # end
  #
  # def self.now_items_include_only_memberships?(cart)
  #   CartItem.where({cart: cart, later: false}).where.not(kind: CartItem::MEMBERSHIP).count == 0
  # end
  #
  # def now_items_include_only_memberships?(c_object)
  #   case
  #   when c_object.kind_of?(Cart)
  #     c_object.reload
  #     return CartItemsHelper.now_items_include_only_memberships?(c_object)
  #   when c_object.kind_of?(CartChassis)
  #     c_object.full_reload
  #     return CartItemLocator.new(our_user: current_user).all_items_for_now_are_memberships?
  #   end
  # end

  def add_admin_buttons(cart_item, deletion: true, availability: true, saving: true)
    [].tap do |buttons|
      if deletion
        if cart_item.item_reservation.present?
          buttons << button_to("Delete", remove_single_cart_item_path(cart_item), method: "delete", data: {confirm: "This membership has already been reserved. When you delete it from your cart, it will not be cancelled, and you will still be able to review and update it from your Membership Page. Delete anyway?" }, class: "btn btn-outline-info")
        else
          buttons << button_to("Delete", remove_single_cart_item_path(cart_item), method: "delete", class: "btn btn-outline-info")
        end
      end

      if saving
        if cart_item.later == true
          buttons << button_to("Move to Cart", move_single_cart_item_path(cart_item), method: "patch", class: "btn btn-outline-info")
        else
          buttons << button_to("Save for Later", save_single_cart_item_path(cart_item), method: "patch", class: "btn btn-outline-info")
        end
      end

      if availability
        buttons << button_to("Check Availability", verify_single_cart_item_path(cart_item), method: "patch", class: "btn btn-outline-info")
      end
    end
  end

  private

  # def destroy_specific_bin_contents(cart: our_cart, now_bin: true)
  #   all_destroyed = true
  #   target_bin = now_bin ? cart.now_bin : cart.later_bin
  #   if cart.present? && target_bin.present? && target_bin.cart_items.present?
  #     target_bin.cart_items.each {|i| i.destroy}
  #     target_bin.reload
  #     all_destroyed = target_bin.cart_items.blank?
  #   end
  #   all_destroyed
  # end

  #TODO: Figure out how much of this failed processing recovery stuff we need or want.
  # def self.recover_failed_processing_items(cart, user)
  #   recovered = 0
  #   if cart.present? && user.present?
  #     fail_carts = Cart.active_processing.where(user: user).where.not(id: cart.id)
  #     if fail_carts.present?
  #       fail_carts.to_ary.each do |f|
  #         f.cart_items.each do |i|
  #           if unprocessed_reservation_item?(f, i)
  #             recovered += 1
  #             i.cart = cart
  #             i.save!
  #           end
  #         end
  #         f.reload
  #         f.status = ::Cart::PAID if mark_failed_cart_paid?(f)
  #         f.active_to = Time.now if mark_failed_cart_inactive?(f)
  #         f.save
  #         # TODO: GET RID OF THIS-- it's just for development
  #         if f.active_and_processing == true
  #           f.cart_items.each {|i|
  #           puts "destroying cart item #{i.id}"
  #           i.destroy }
  #           puts "destroying cart #{f}"
  #           f.destroy
  #         end
  #       end
  #     end
  #     cart.reload
  #   end
  #   recovered
  # end
  #
  # def recover_failed_processing_items(cart, user)
  #   CartItemsHelper.recover_failed_processing_items(cart, user)
  # end
  #
  # def self.unprocessed_reservation_item?(cart, item)
  #   return false if (cart.status != PROCESSING || cart.active? == false)
  #   return true if (item.kind == MEMBERSHIP && !item.item_reservation.present?)
  #   unprocessed = false
  #   if (item.item_reservation.present? && item.item_reservation.state == ::Reservation::INSTALMENT &&  item.acquirable.price > 0)
  #     unprocessed = (AmountOwedForReservation.new(item.item_reservation).amount_owed == item.acquirable.price)
  #   end
  #   unprocessed
  # end
  #
  # def unprocessed_reservation_item?(cart, item)
  #   CartItemsHelper.unprocessed_reservation_item?(cart, item)
  # end
  #
  # def self.mark_failed_cart_paid?(cart)
  #   return false if cart.status != PROCESSING
  #   return false if cart.cart_items.empty?
  #   mark_paid = true
  #   cart.cart_items.each do |i|
  #     if i.item_reservation.present?
  #       mark_paid = false if (i.item_reservation.state == INSTALLMENT) && (AmountOwedForReservation.new(i.item_reservation).amount_owed) > 0
  #     end
  #   end
  #   mark_paid
  # end
  #
  # def mark_failed_cart_paid?(cart)
  #   CartItemsHelper.mark_failed_cart_paid?(cart)
  # end
  #
  # def self.mark_failed_cart_inactive?(cart)
  #   cart.reload
  #   return false if cart.status != PROCESSING
  #   return true if cart.cart_items.empty?
  # end
  #
  # def mark_failed_cart_inactive?(cart)
  #   CartItemsHelper.mark_failed_cart_inactive?(cart)
  # end



  # def self.mark_cart_items_processed(cart, now_items_only = false)
  #   cart.reload
  #   cart.cart_items.each do |i|
  #     i.processed = true if (!i.later || !now_items_only)
  #     i.save!
  #   end
  # end
  #
  # def mark_cart_items_processed(cart, now_items_only = false)
  #   CartItemsHelper.mark_cart_items_processed(cart, now_items_only)
  # end
  #
  # def self.stamp_cart_inactive(cart)
  #   cart.active_to = Time.now
  #   cart.save!
  #   cart.reload
  # end
  #
  # def stamp_cart_inactive(cart)
  #   CartItemsHelper.stamp_cart_inactive(cart)
  # end
  #
  # def self.post_payment_housekeeping(cart, now_items_only = false)
  #   cart.reload
  #   mark_cart_items_processed(cart, now_items_only)
  #   stamp_cart_inactive(cart)
  # end
  #
  # def post_payment_housekeeping(cart, now_items_only = false)
  #   CartItemsHelper.post_payment_housekeeping(cart, now_items_only)
  # end
end
