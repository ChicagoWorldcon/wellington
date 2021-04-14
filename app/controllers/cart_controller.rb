# frozen_string_literal: true
#
# Copyright 2020, 2021 Victoria Garcia
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

class CartController < ApplicationController
  include ThemeConcern
  helper ApplicationHelper
  helper CartItemsHelper
  helper ChargesHelper

  before_action :require_nonsupport_login
  before_action :get_cart_chassis
  before_action :locate_target_item, only: [:remove_single_item, :save_item_for_later, :move_item_to_cart, :verify_single_item_availability]
  #before_action :verify_all_cart_contents, only: [:show]

  MEMBERSHIP = "membership"
  FOR_LATER = "for_later"
  FOR_NOW = "for_now"

  def show
    prep_bins
    render :cart
  end

  def add_reservation_to_cart
    new_cart_item = CartServices::ResolveCartItem.new(
      full_params: params,
      bin_for_now: @cart_chassis.now_bin,
      item_kind: MEMBERSHIP,
      flash_obj: flash
    ).call

    if new_cart_item.present? && new_cart_item.save
      flash[:status] = :success
      flash[:notice] = "Membership successfully added to cart."
      prep_bins
      redirect_to cart_path and return
    end

    flash[:messages] = new_cart_item.errors.messages
    prep_bins
    redirect_back(fallback_location: root_path)
  end

  def destroy
    destroyed = @cart_chassis.destroy_all_cart_contents
    if destroyed
      flash[:status] = :success
      flash[:notice] = "Your cart is now empty."
    else
      flash[:status] = :failure
      flash[:notice] = "Your cart could not be fully emptied."
    end

    prep_bins
    redirect_to cart_path
  end

  def destroy_active
    destroyed = @cart_chassis.destroy_all_items_for_now
    if destroyed
      flash[:status] = :success
      flash[:notice] = "Your cart is now empty."
    else
      flash[:status] = :failure
      flash[:notice] = "Your cart could not be fully emptied."
    end

    prep_bins
    redirect_to cart_path
  end

  def destroy_saved
    destroyed = @cart_chassis.destroy_all_items_for_later

    if destroyed
      flash[:status] = :success
      flash[:notice] = "Your cart is now empty."
    else
      flash[:status] = :failure
      flash[:notice] = "Your cart could not be fully emptied."
    end

    prep_bins
    redirect_to cart_path
  end

  def remove_single_item
    single_item_remove
    prep_bins
    redirect_back(fallback_location: cart_path)
  end

  def save_item_for_later
    single_item_save
    prep_bins
    redirect_back(fallback_location: cart_path)
  end

  def move_item_to_cart
    single_item_unsave
    prep_bins
    redirect_back(fallback_location: cart_path)
  end

  def save_all_items_for_later
    lingering_n = @cart_chassis.save_all_items_for_later

    case lingering_n
    when -1
      flash[:alert] = "There was a problem with your cart. Some items may not have been saved."
    when 0
      flash[:notice] = "All active items have now been saved for later."
    else
      flash[:alert] = "One or more items could not be saved for later"
    end

    prep_bins
    redirect_to cart_path
  end

  def move_all_saved_items_to_cart
    lingering_l = @cart_chassis.move_all_saved_to_cart

    case lingering_l
    when -1
      flash[:alert] = "There was a problem with your cart. Some items may not have been moved."
    when 0
      flash[:notice] = "All items have now been moved to the cart."
    else
      flash[:alert] = "One or more items could not be moved to the cart"
    end

    prep_bins
    redirect_to cart_path
  end

  def verify_single_item_availability
    single_item_availability_check
    @cart_chassis.full_reload
    prep_bins
    redirect_back(fallback_location: cart_path)
  end

  def verify_all_items_availability
    verify_all_cart_contents
    @cart_chassis.full_reload
    prep_bins
    redirect_back(fallback_location: cart_path)
  end

  def preview_online_purchase

    if @cart_chassis.now_items_count == 0
      flash[:notice] = "There is nothing in your cart to purchase! (Hint: check to see if you've saved the thing(s) you want for later.)"
      redirect_to cart_path and return
    end

    if !now_items_confirmed_ready_for_payment?
      flash[:notice] = "Please review your cart."
      prep_bins
      redirect_to cart_path and return
    end

    @expected_charge = @cart_chassis.purchase_subtotal
    @items_for_purchase = @cart_chassis.now_items
    prep_bins
  end

  def submit_online_payment
    check_for_paid
    prep_results = prepare_cart_for_payment
    @cart_chassis.full_reload
    @transaction_cart = @cart_chassis.purchase_bin
    @prospective_charge_cents = @cart_chassis.purchase_subtotal_cents
    flash[:notice] = "Your requested reservations have been created."
    prep_bins
  end

  def pay_with_cheque
    prep_results = prepare_cart_for_payment
    if prep_results[:good_to_go]
      CartServices::WaitForCheckHousekeeping.new(@cart_chassis).call
      flash[:notice] = "Your requested reservations have been created. See your email for instructions on payment by cheque."
    end
    redirect_to reservations_path
  end

  private

  def require_nonsupport_login
    if support_signed_in?
      flash[:alert] = "You are currently logged in as support staff. If you are a support user attempting to make personal purchases, please log in to your personal (nonsupport) account."
      redirect_to root_path and return
    elsif !user_signed_in?
      flash[:alert] = "You must be signed in to access the cart."
      redirect_to root_path and return
    end
  end

  def get_cart_chassis
    @cart_chassis ||= nil
    unless (@cart_chassis.try(:now_bin) && @cart_chassis.try(:later_bin))
      r_c_serv = CartServices::ResolveCartChassis.new(user: current_user, existing_cart_chassis: @cart_chassis).call
      if r_c_serv[:cart_chassis].present?
        @cart_chassis = r_c_serv[:cart_chassis]
      else
        flash[:alert] = r_c_serv[:errors]
      end
    end
  end

  def locate_target_item
    @target_item = CartItemsHelper.locate_cart_item(current_user, params[:id])
    if @target_item.blank?
      flash[:alert] = "Unable to recognize this item."
      prep_bins
      redirect_back(fallback_location: cart_path) and return
    end
  end

  def verify_all_cart_contents
    veri = @cart_chassis.verify_avail_for_all_items

    if !veri[:verified]
      flash[:alert] = "The following items are no longer available: #{veri[:problem_items].join(', ')}"
    else
      flash[:notice] = "Good news! Everything in your cart is still available."
    end

    veri[:verified]
  end

  def now_items_confirmed_ready_for_payment?
    ready = @cart_chassis.can_proceed_to_payment?
    unless ready[:verified]
      flash[:alert] = "There are problems with the following items: #{ready[:problem_items].join(', ')}" if ready[:problem_items].present?
      @cart_chassis.full_reload
    end
    ready[:verified]
  end

  def single_item_availability_check
    available = false
    if @target_item.item_still_available?
      available = true
      flash[:notice] = "Good news! #{@target_item.item_display_name} is still available."
    else
      flash[:alert] = "#{@target_item.item_display_name} is no longer available."
    end
    available
  end

  def single_item_save
    return unless @target_item && @cart_chassis
    saved = @cart_chassis.move_item_to_saved(@target_item)
    if saved
      flash[:notice] = "Item successfully saved for later."
    else
      flash[:notice] = "This item could not be saved for later."
      flash[:messages] = @target_item.errors.messages
    end
    saved
  end

  def single_item_unsave
    return unless @target_item && @cart_chassis
    unsaved = @cart_chassis.move_item_to_cart(@target_item)
    if unsaved
      flash[:notice] = "Item successfully moved to the cart."
    else
      flash[:notice] = "This item could not be moved to the cart."
      flash[:messages] = @target_item.errors.messages
    end
    unsaved
  end

  def single_item_remove
    removed = false
    if @target_item
      target_item_name = @target_item.item_display_name
      target_item_kind = @target_item.kind
      if @target_item.destroy
        removed = true
        flash[:notice] = "#{target_item_name} #{target_item_kind} was successfully deleted"
      else
        flash[:alert] = "#{target_item_name} #{target_item_kind} could not be removed from your cart."
      end
    end
    removed
  end

  def prepare_cart_for_payment
    check_for_paid

    if !now_items_confirmed_ready_for_payment?
      flash[:notice] = "Please review your cart before proceeding."
      prep_bins
      redirect_to cart_path and return
    end

    cart_prep_results = CartServices::PrepCartForPayment.new(@cart_chassis).call

    if !cart_prep_results[:good_to_go]
      flash[:alert] = "There was a problem with one or more of your items!"
      prep_bins
      redirect_to cart_path and return
    end

    if cart_prep_results[:amount_to_charge] == 0
      flash[:notice] = "None of your items require payment."
      redirect_to reservations_path and return
    end

    cart_prep_results
  end

  def check_for_paid
    @cart_chassis.full_reload
    if @cart_chassis.purchase_bin.paid?
      redirect_to reservations_path, notice: "You've paid for this order already." and return
    end
  end

  def prep_bins
    get_cart_chassis
    @cart_chassis.full_reload
    @now_bin = @cart_chassis.now_items
    @later_bin = @cart_chassis.later_items
    @now_subtotal = @cart_chassis.purchase_subtotal
  end
end
