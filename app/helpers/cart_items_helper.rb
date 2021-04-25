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

  FULL = "full"
  PARTIAL = "partial"
  NONE = "none"
  NO_RESERVATION = "no_reservation"

  def self.reservation_payment_status(c_item)
    return {payment_status: NO_RESERVATION, status_desc: "Not reserved."} if !c_item.item_reservation.present?

    owed = AmountOwedForReservation.new(c_item.item_reservation).amount_owed.cents
    payment_recorded = ReservationPaymentHistory.new(c_item.item_reservation).any_successful_charges?

    return {payment_status: FULL, status_desc: "Reserved and paid in full."} if owed <= 0
    return {payment_status: PARTIAL, status_desc: "Reserved and paid in part."} if payment_recorded
    {payment_status: NONE, status_desc: "Reserved but not yet paid"}
  end

  def reservation_payment_status(c_item)
    CartItemsHelper.reservation_payment_status(c_item)
  end

  def self.locate_cart_item(user, cart_item_id)
    locator = CartItemLocator.new(our_user: user, our_item_id: cart_item_id)
    locator.locate_current_cart_item_for_user
  end

  def locate_cart_item(cart_item_id)
    CartItemsHelper.locate_cart_item(cart_item_id)
  end

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

  def reserve_and_pay_button_text(cart_chassis)
    anything_left_to_reserve = ReservationsInCart.new(cart_chassis.purchase_bin).reservations_gathered.count < cart_chassis.items_to_purchase_count
    anything_left_to_reserve ? "Reserve and Pay Online Now" : "Pay Online Now"
  end

  def group_deletion_button(cart_object)
    reservation_warning_needed = false

    confirm_hash = {
      confirm: confirm_text(true) }

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

  def add_admin_buttons(cart_item, deletion: true, availability: true, saving: true, in_later_bin: false)
    [].tap do |buttons|
      if deletion
        if cart_item.item_reservation.present?
          buttons << button_to("Delete", remove_single_cart_item_path(cart_item), method: "delete", data: {confirm: confirm_text(false) }, class: "btn btn-outline-info")
        else
          buttons << button_to("Delete", remove_single_cart_item_path(cart_item), method: "delete", class: "btn btn-outline-info")
        end
      end

      if saving
        if in_later_bin == true
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

  def confirm_text(for_group)
    lagging_text = " has already been reserved. When you delete it from your cart, it will not be cancelled, and you will still be able to review, update, and make payments on it from your Membership Page. Delete anyway?"

    leading_text = for_group ? "One or more memberships"  : "This membership"

    leading_text + lagging_text
  end
end
