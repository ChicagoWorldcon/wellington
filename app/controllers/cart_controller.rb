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
  before_action :locate_cart
  before_action :locate_target_item, only: [:remove_single_item, :save_item_for_later, :move_item_to_cart, :verify_single_item_availability, :remove_single_checkout_item, :save_single_checkout_item_for_later, :check_single_checkout_item_availability]

  before_action :verify_all_cart_contents, only: [:move_all_saved_items_to_cart]
  #before_action :all_contents_confirmed_ready_for_payment?, only:[:pay_with_cheque]
  before_action :now_items_confirmed_ready_for_payment?, only:[:submit_online_payment, :pay_with_cheque]

  before_action :locate_membership_offer_via_params, only: [:add_reservation_to_cart]
  before_action :generate_membership_beneficiary_from_params, only: [:add_reservation_to_cart]

  PENDING = "pending"
  MEMBERSHIP = "membership"
  FOR_LATER = "for_later"

  def show
    render :cart
  end

  def add_reservation_to_cart
    if (@our_offer.present? && @our_beneficiary.present?)
      @our_cart_item = CartItem.create(
        :acquirable => @our_offer.membership,
        :cart => @cart,
        :benefitable => @our_beneficiary,
        :kind => MEMBERSHIP
      )
      if @our_cart_item.save
        flash[:status] = :success
        flash[:notice] = "Membership successfully added to cart."
        @cart.reload
        redirect_to cart_path and return
      end
    end
    flash[:messages] = @our_cart_item.errors.messages
    redirect_back(fallback_location: root_path)
  end

  def destroy
    # This empties the cart of all items, both active and saved.
    CartItemsHelper.destroy_cart_contents(@cart)
    @cart.reload
    if @cart.cart_items.count == 0
      flash[:status] = :success
      flash[:notice] = "Your cart is now empty."
    else
      flash[:status] = :failure
      flash[:notice] = "Your cart could not be fully emptied."
    end
    redirect_to cart_path
  end

  def destroy_active
    CartItemsHelper.destroy_for_now_cart_items(@cart)
    @cart.reload
    if CartItemsHelper.cart_items_for_now(@cart).count == 0
      flash[:status] = :success
      flash[:notice] = "Active cart successfully emptied!"
    else
      flash[:status] = :failure
      flash[:notice] = "One or more items could not be deleted."
    end
    @cart.reload
    redirect_to cart_path
  end

  def destroy_saved
    CartItemsHelper.destroy_cart_items_for_later(@cart)
    @cart.reload
    if CartItemsHelper.cart_items_for_later(@cart).count == 0
      flash[:status] = :success
      flash[:notice] = "Saved items successfully cleared!"
    else
      flash[:status] = :failure
      flash[:result_text] = "One or more items could not be deleted."
    end
    redirect_to cart_path
  end

  def remove_single_item
    single_item_remove
    @cart.reload
    redirect_to cart_path
  end

  def save_item_for_later
    single_item_save
    @cart.reload
    redirect_to cart_path
  end

  def save_all_items_for_later
    CartItemsHelper.save_all_cart_items_for_later(@cart)
    @cart.reload
    if CartItemsHelper.cart_items_for_now(@cart).count == 0 && CartItemsHelper.cart_items_for_later(@cart).count > 0
        flash[:notice] = "All active items have now been saved for later."
      else
        flash[:notice] = "One or more items could not be saved for later"
    end
    redirect_to cart_path
  end

  def move_item_to_cart
    @target_item.later = false
    if @target_item.save
      flash[:status] = :success
      flash[:notice] = "Item successfully moved to cart."
    else
      flash[:status] = :failure
      flash[:notice] = "This item could not be moved to the cart."
      flash[:messages] = @target_item.errors.messages
    end
    redirect_to cart_path
  end

  def move_all_saved_items_to_cart
    if @cart.cart_items.present?
      all_moved = CartItemsHelper.unsave_all_cart_items(@cart)
      if !all_moved
        flash[:notice] = "One or more of your items could not be moved to the cart"
      else
        flash[:notice] = "All saved items have been successfully moved to the cart."
      end
    else
      flash[:notice] = "No saved items found"
    end
    @cart.reload
    redirect_to cart_path
  end


  def verify_single_item_availability
    single_item_availability_check
    @cart.reload
    redirect_to cart_path
  end

  def verify_all_items_availability
    verify_all_cart_contents
    redirect_to cart_path
  end

  def preview_online_purchase
    recovereds = CartServices::RecoverFailedProcessingItems.new(@cart, current_user).call
    @cart.reload

    if CartItemsHelper.cart_items_for_now(@cart).blank?
      flash[:notice] = "There is nothing in your cart to purchase! (Hint: check to see if you've saved the thing(s) you want for later.)"
      redirect_to cart_path and return
    elsif recovereds > 0
      flash[:notice] = "#{recovereds} previously-added item(s) found.  Please review them before proceeding to purchase preview."
      redirect_to cart_path and return
    elsif !now_items_confirmed_ready_for_payment?
      flash[:notice] = "There is a problem with one or more of your items.  Please review the contents of your cart before proceeding to payment."
      redirect_to cart_verify_all_path and return
    else
      @check_button = just_buying_memberships?
      @expected_charge = @cart.subtotal_display
      @items_for_purchase = @cart.items_for_now
    end
  end

  def remove_single_checkout_item
    single_item_remove
    @cart.reload
    # @expected_charge = @cart.subtotal_display
    redirect_to cart_preview_online_purchase_path
  end

  def save_single_checkout_item_for_later
    single_item_save
    @cart.reload
    # @expected_charge = @cart.subtotal_display
    redirect_to cart_path
  end

  def check_single_checkout_item_availability
    single_item_availability_check
    @cart.reload
    # @expected_charge = @cart.subtotal_display
    redirect_to cart_preview_online_purchase_path
  end

  def submit_online_payment
    confirm_ready_to_proceed

    transaction_results = ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      prep_service = CartServices::PrepCartForPayment.new(@cart)
      our_results = prep_service.call
    end

    if transaction_results[:amount_to_charge] == 0
      flash[:notice] = "None of your items require payment."
      # TODO: Figure out if this is the correct redirect
      redirect_to reservations_path and return
    end

    if !transaction_results[:good_to_go]
      flash[:alert] = "There was a problem with one or more of your items!"
      CartServices::RecoverFailedProcessingItems.new(@cart, current_user).call
      @cart.reload
      #TODO:  Maybe use the _payment_problem.html.erb partial here
      redirect_to cart_path and return
    end

    @processing_cart = transaction_results[:processing_cart]
    @prospective_charge_formatted = transaction_results[:amount_to_charge]
    @prospective_charge_cents = transaction_results[:amount_to_charge].cents
    #TODO: Refine this message.
    flash[:notice] = "Your requested reservations have been created."

    render :submit_online_payment
  end

  def pay_with_cheque
    #TODO: fix Ready to Proceed issue
    # confirm_ready_to_proceed

    transaction_results = ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
      prep_service = CartServices::PrepCartForPayment.new(@cart)
      our_results = prep_service.call
      # our_results
    end

    if !transaction_results[:good_to_go]
      flash[:alert] = "There was a problem with one or more of your items!"
      CartServices::RecoverFailedProcessingItems.new(@cart, current_user).call
      @cart.reload
      #TODO:  Maybe use the _payment_problem.html.erb partial here
      redirect_to cart_path and return
    end

    if transaction_results[:amount_to_charge] == 0
      flash[:notice] = "None of your items require payment."
    end

    flash[:notice] = "Your requested reservations have been created. See your email for instructions on payment by cheque."

    transaction_results[:processing_cart].status = Cart::AWAITING_CHEQUE
    transaction_results[:processing_cart].save

    owed_for_mailer = transaction_results[:amount_to_charge].kind_of?(Integer) ? transaction_results[:amount_to_charge] : transaction_results[:amount_to_charge].cents

     trigger_cart_waiting_for_cheque_payment_mailer(transaction_results[:processing_cart], owed_for_mailer)

    redirect_to reservations_path
  end

  ###############################
  # Don't Know If I Need These: #
  ###############################

  def edit_single_item
    # This will be for going into the reservation data, in theory
    # TODO: figure out if we need this.
  end

  def update
    # TODO: Figure out if this, or some form of this, is actually necessary.
  end

  def update_cart_info
    # TODO: figure out if this is necessary.
    # IF I ACTUALLY USE THIS it will be for shipping and billing-type stuff.
  end

  private

  def require_nonsupport_login
    binding.pry
    if support_signed_in?
      binding.pry
      flash[:alert] = "You are currently logged in as support staff. If you are a support user attempting to make personal purchases, please log in to your personal (nonsupport) account."
      redirect_to root_path and return
    elsif !user_signed_in?
      flash[:alert] = "You must be signed in to access the cart."
      redirect_to root_path and return
    end
  end

  def locate_cart
    @cart ||= Cart.active_pending.find_by(user: current_user)
    @cart ||= create_cart
    if @cart.nil?
      flash[:status] = :failure
      flash[:notice] = "We were unable to find or create your shopping cart."
      redirect_to memberships_path
    else
      CartServices::RecoverFailedProcessingItems.new(@cart, current_user).call
    end
  end

  def locate_pending_cart
    @cart ||= Cart.active_pending.find_by(user: current_user)
    @cart ||= create_cart(with_status: PENDING)
  end

  def locate_cart_for_later
    @cart ||= Cart.active_pending.find_by(user: current_user)
    @cart ||= create_cart(with_status: FOR_LATER)
  end

  def locate_target_item
    @target_item = CartItemsHelper.locate_cart_item_with_cart(params[:id], @cart.id)
    if @target_item.blank?
      flash[:alert] = "Unable to recognize this item."
      render :cart and return
    end
  end

  def locate_all_active_cart_items
    @now_cart_items = CartItemsHelper.cart_items_for_now(@cart)
  end

  def locate_all_cart_items_for_later
    @later_cart_items = CartItemsHelper.cart_items_for_later(@cart)
  end

  def locate_all_cart_items
    @all_cart_items = @cart.cart_items
  end

  def locate_membership_offer_via_params
    @our_offer = MembershipOffer.locate_active_offer_by_hashcode(params[:offer])
    if !@our_offer.present?
      flash[:error] = t("errors.offer_unavailable", offer: params[:offer])
      redirect_back(fallback_location: memberships_path) and return
    end
  end

  def generate_membership_beneficiary_from_params
    @our_beneficiary = theme_contact_class.new(our_contact_params)
    if @our_beneficiary.present?
      process_beneficiary_dob
      validate_beneficiary
    end
  end

  def single_item_is_available?
    @target_item.item_still_available?
  end

  def create_cart(with_status: PENDING)
    # Status PENDING is for the part of the cart where active items go.
    # Status FOR_LATER is for the part of the cart where saved items go.
    if user_signed_in? && !support_signed_in?
      @cart = Cart.new status: with_status
      # current_user is a Devise helper.
      @cart.user_id = User.find_by(id: current_user.id).id
      @cart.active_from = Time.now
      if @cart.save
        flash[:status] = :success
      else
        flash[:status] = :failure
        flash[:notice] = "We weren't able to fully create your shopping cart."
        flash[:messages] = @cart.errors.messages
      end
      return @cart
    end
  end

    # TODO: Only allow a list of trusted parameters through.
  # def cart_params
  #   params.fetch(:cart, {})
  # end

  def our_contact_params
    return params.require(theme_contact_param).permit(theme_contact_class.const_get("PERMITTED_PARAMS"))
  end

  def validate_beneficiary
    if !@our_beneficiary.valid?
      flash[:error] = @our_beneficiary.errors.full_messages.to_sentence(words_connector: ", and ").humanize.concat(".")
      # TODO: Make sure this is what you want to render.
      redirect_back(fallback_location: root_path) and return
    else
      @our_beneficiary.save
    end
  end

  def process_beneficiary_dob
    our_dob = DateOfBirthParamsHelper.generate_dob_from_params(params)
    if our_dob
      @our_beneficiary.date_of_birth = our_dob
    end
  end

  def verify_all_cart_contents
    verified = true
    if !CartItemsHelper.verify_availability_of_cart_contents(@cart)
      flash[:alert] = "One or more of your items is no longer available."
      verified = false
    end
    verified
  end

  def now_items_confirmed_ready_for_payment?
    confirmed = true
    if !CartItemsHelper.cart_contents_ready_for_payment?(@cart, now_items_only: true)
      flash[:alert] = "there is a problem with one or more of your items."
      confirmed = false
      @cart.reload
    end
    confirmed
  end

  def single_item_remove
    removed = false
    if @target_item
      target_item_name = @target_item.item_display_name
      target_item_kind = @target_item.kind
      @target_item.destroy
      removed = true
      flash[:notice] = "#{@target_item_name} #{@target_item_kind} was successfully deleted"
    else
      flash[:alert] = "This item could not be removed from your cart."
      if @cart
        flash[:errors] = @cart.errors.messages
      end
    end
    removed
  end

  def single_item_save
    saved = false
    if @target_item
      @target_item.later = true
      if @target_item.save
        saved = true
        flash[:notice] = "Item successfully saved for later."
      end
    else
      flash[:notice] = "This item could not be saved for later."
      flash[:messages] = @cart.errors.messages
    end
    saved
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

  def just_buying_memberships?
    CartItemsHelper.now_items_include_only_memberships?(@cart)
  end

  def confirm_ready_to_proceed
    recovereds = CartServices::RecoverFailedProcessingItems.new(@cart, current_user).call
    if recovereds > 0
      flash[:notice] = "#{recovereds} previously-added item(s) found.  Please review them before proceeding."
      redirect_to cart_path and return
    end
    if !now_items_confirmed_ready_for_payment?
      flash[:notice] = "There is a problem with one or more of your items.  Please review your cart before proceeding."
      redirect_to cart_verify_all_path and return
    end
  end

  def trigger_cart_waiting_for_cheque_payment_mailer(cart, amount_outstanding)
    item_descs = CartContentsDescription.new(
      cart,
      with_layperson_uniq_id: true,
      for_email: true,
      force_full_contact_name: true
    ).describe_cart_contents

    PaymentMailer.cart_waiting_for_cheque(
      user: current_user,
      item_count: cart.cart_items.size,
      outstanding_amount: amount_outstanding,
      item_descriptions: item_descs,
      transaction_date: Time.now,
      cart_number: cart.id
    ).deliver_later
  end
end
