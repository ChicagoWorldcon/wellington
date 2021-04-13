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
  #before_action :locate_cart
  before_action :get_cart_chassis

  before_action :locate_target_item, only: [:remove_single_item, :save_item_for_later, :move_item_to_cart, :verify_single_item_availability]

  #before_action :verify_all_cart_contents, only: [:show]

  #PENDING = "pending"
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
    #
    # defacto_cart = @cart if @cart.present?
    # defacto_cart ||= @cart_chassis
    # #CartItemsHelper.destroy_cart_contents(defacto_cart)
    # CartItemsHelper.cart_contents_destroyer(defacto_cart)
    destroyed = @cart_chassis.destroy_all_cart_contents
    if destroyed
      flash[:status] = :success
      flash[:notice] = "Your cart is now empty."
    else
      flash[:status] = :failure
      flash[:notice] = "Your cart could not be fully emptied."
    end
    # if @cart.present?
    #   @cart.reload
    #   if @cart.cart_items.count == 0
    #     flash[:status] = :success
    #     flash[:notice] = "Your cart is now empty."
    #   else
    #     flash[:status] = :failure
    #     flash[:notice] = "Your cart could not be fully emptied."
    #   end
    # elsif @cart_chassis.present?
    #   @cart_chassis.full_reload
    #   if @cart_chassis.all_items_count == 0
    #     flash[:status] = :success
    #     flash[:notice] = "The thing's empty. Groovy."
    #   else
    #     flash[:status] = :failure
    #     flash[:notice] = "The thing's still got stuff in it. Boners."
    #   end
    # end

    prep_bins
    redirect_to cart_path
  end

  def destroy_active
    # defacto_cart = @cart if @cart.present?
    # defacto_cart ||= @cart_chassis
    #
    #
    #
    #
    # destroy_for_now_cart_items(defacto_cart)
    # @cart.reload
    # if CartItemsHelper.cart_items_for_now(@cart).count == 0
    #   flash[:status] = :success
    #   flash[:notice] = "Active cart successfully emptied!"
    # else
    #   flash[:status] = :failure
    #   flash[:notice] = "One or more items could not be deleted."
    # end
    # @cart.reload
    destroyed = @cart_chassis.destroy_all_items_for_now
    if destroyed
      flash[:status] = :success
      flash[:notice] = "Your cart is now empty."
    else
      flash[:status] = :failure
      flash[:notice] = "Your cart could not be fully emptied."
    end
    #
    # if @cart.present?
    #   @cart.reload
    #   if CartItemsHelper.cart_items_for_now(@cart).count == 0
    #     flash[:status] = :success
    #     flash[:notice] = "Your cart is now empty."
    #   else
    #     flash[:status] = :failure
    #     flash[:notice] = "Your cart could not be fully emptied."
    #   end
    # elsif @cart_chassis.present?
    #   @cart_chassis.full_reload
    #   if @cart_chassis.now_items_count == 0
    #     flash[:status] = :success
    #     flash[:notice] = "The right-now stuff is dumped. Thrilling!"
    #   else
    #     flash[:status] = :failure
    #     flash[:notice] = "Some right-now stuff is still stuck here. Bleh."
    #   end
    # end
    prep_bins
    redirect_to cart_path
  end

  def destroy_saved
    # defacto_cart = @cart if @cart.present?
    # defacto_cart ||= @cart_chassis
    #
    # destroy_cart_items_for_later(defacto_cart)
    #
    # @cart.reload if @cart.present?
    # @cart_chassis.full_reload if @cart_chassis.present?
    #
    # survivors = nil
    # if defacto_cart.kind_of?(Cart)
    #   survivors = cart_items_for_later(defacto_cart)
    # elsif defactoIcart.kind_of?(CartChassis)
    #   survivors = defacto_cart.all_items_count
    # end
    #
    # if survivors === 0
    #   flash[:status] = :success
    #   flash[:notice] = "Saved items successfully cleared!"
    # else
    #   flash[:status] = :failure
    #   flash[:result_text] = "One or more items could not be deleted."
    # end

    destroyed = @cart_chassis.destroy_all_items_for_later
    if destroyed
      flash[:status] = :success
      flash[:notice] = "Your cart is now empty."
    else
      flash[:status] = :failure
      flash[:notice] = "Your cart could not be fully emptied."
    end
    #

    prep_bins
    redirect_to cart_path
  end

  def remove_single_item
    # defacto_cart = @cart if @cart.present?
    # defacto_cart ||= @cart_chassis
    single_item_remove
    #
    #
    # @cart.reload if @cart.present?
    # @cart_chassis.full_reload if @cart_chassis.present?

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
    # defacto_cart = @cart if @cart.present?
    # defacto_cart ||= @cart_chassis
    #
    # @target_item.later = false
    # @target_item.cart = defacto_cart.kind_of?(CartChassis) ? defacto_cart.now_bin : defacto_cart
    #
    # if @target_item.save
    #   flash[:status] = :success
    #   flash[:notice] = "Item successfully moved to cart."
    # else
    #   flash[:status] = :failure
    #   flash[:notice] = "This item could not be moved to the cart."
    #   flash[:messages] = @target_item.errors.messages
    # end

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
    # defacto_cart = @cart if @cart.present?
    # defacto_cart ||= @cart_chassis
    #
    # all_moved = nil
    # something_movable = false

    lingering_l = @cart_chassis.move_all_saved_to_cart

    # if defacto_cart.kind_of?(CartChassis)
    #   something_movable = defacto_cart.later_bin.cart_items.present?
    #   all_moved = (defacto_cart.move_all_saved_to_cart == 0) if something_movable
    #   defacto_cart.full_reload
    # elsif defacto_cart.kind_of?(Cart)
    #   something_movable = cart_items_for_later(defacto_cart).present?
    #   all_moved = unsave_all_cart_items(defacto_cart) if something_movable
    #   defacto_cart.reload
    # end
    case lingering_l
    when -1
      flash[:alert] = "There was a problem with your cart. Some items may not have been moved."
    when 0
      flash[:notice] = "All items have now been moved to the cart."
    else
      flash[:alert] = "One or more items could not be moved to teh cart"
    end

    # if something_movable
    #   if !all_moved
    #     flash[:notice] = "One or more of your items could not be moved to the cart"
    #   else
    #     flash[:notice] = "All saved items have been successfully moved to the cart."
    #   end
    # else
    #   flash[:notice] = "No saved items found"
    # end

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

    # if @cart.present?
    #   recovereds = CartServices::RecoverFailedProcessingItems.new(@cart, current_user).call
    #   @cart.reload
    #
    #   if CartItemsHelper.cart_items_for_now(@cart).blank?
    #     flash[:notice] = "There is nothing in your cart to purchase! (Hint: check to see if you've saved the thing(s) you want for later.)"
    #     prep_bins
    #     redirect_to cart_path and return
    #   elsif recovereds > 0
    #     flash[:notice] = "#{recovereds} previously-added item(s) found.  Please review them before proceeding to purchase preview."
    #     prep_bins
    #     redirect_to cart_path and return
    #   elsif !now_items_confirmed_ready_for_payment?
    #     flash[:notice] = "There is a problem with one or more of your items.  Please review the contents of your cart before proceeding to payment."
    #     prep_bins
    #     redirect_to cart_path and return
    #   else
    #     @check_button = just_buying_memberships?
    #     @expected_charge = @cart.subtotal_display
    #     @items_for_purchase = @cart.items_for_now
    #   end

    if @cart_chassis.now_items_count == 0
      flash[:notice] = "There is nothing in your cart to purchase! (Hint: check to see if you've saved the thing(s) you want for later.)"
      redirect_to cart_path and return
    end

    # recovereds = CartServices::RecoverFailedProcessingItems.new(@cart_chassis.now_bin, current_user).call
    # @cart_chassis.full_reload
    #
    # if recovereds > 0
    #   flash[:notice] = "There were #{recovereds} goobered-up items found.  What?? That's not supposed to happen anymore."
    #   prep_bins
    #   redirect_to cart_path and return
    # end

    if !now_items_confirmed_ready_for_payment?
      flash[:notice] = "Please review your cart."
      prep_bins
      redirect_to cart_path and return
    end

    @check_button = @cart_chassis.payment_by_check_allowed?
    @expected_charge = @cart_chassis.purchase_subtotal
    @items_for_purchase = @cart_chassis.now_items
    prep_bins
  end


  # def remove_single_checkout_item
  #   #TODO: remove this from routing and use the method above.
  #   single_item_remove
  #
  #   @cart.reload if @cart.present?
  #   @cart_chassis.full_reload if @cart_chassis.present?
  #   # @expected_charge = @cart.subtotal_display
  #
  #   prep_bins
  #   redirect_back(fallback_location: cart_path)
  # end
  #
  # def save_single_checkout_item_for_later
  #   #TODO: remove this from routing and use the method above.
  #   single_item_save
  #
  #   @cart.reload if @cart.present?
  #   @cart_chassis.full_reload if @cart_chassis.present?
  #   # @expected_charge = @cart.subtotal_display
  #   prep_bins
  #   redirect_back(fallback_location: cart_path)
  # end
  #
  # def check_single_checkout_item_availability
  #   #TODO: remove this from routing and use the method above.
  #   single_item_availability_check
  #
  #   @cart.reload if @cart.present?
  #   @cart_chassis.full_reload if @cart_chassis.present?
  #
  #   prep_bins
  #
  #   redirect_back(fallback_location: cart_path)
  # end

  ###REFACTORING_STARTS

  def submit_online_payment
    # confirm_ready_to_proceed
    # cart_prep_results = CartServices::PrepCartForPayment.new(@cart_chassis).call
    #
    # if transaction_results[:amount_to_charge] == 0
    #   flash[:notice] = "None of your items require payment."
    #   redirect_to reservations_path and return
    # end
    #
    # if !transaction_results[:good_to_go]
    #   flash[:alert] = "There was a problem with one or more of your items!"
    #   #
    #   # recovery_cart = @cart_chassis.now_bin
    #   # CartServices::RecoverFailedProcessingItems.new(recovery_cart, current_user).call
    #   # @cart_chassis.full_reload
    #   # #TODO:  Maybe use the _payment_problem.html.erb partial here
    #   prep_bins
    #   redirect_to cart_path and return
    # end

    check_for_paid
    prep_results = prepare_cart_for_payment
    #return if !prep_results || !prep_results[:good_to_go]
    binding.pry
    @cart_chassis.full_reload
    binding.pry
    @transaction_cart = @cart_chassis.purchase_bin
    @prospective_charge_formatted = Money.new(@cart_chassis.purchase_subtotal_cents)
    @prospective_charge_cents = @cart_chassis.purchase_subtotal_cents
    flash[:notice] = "Your requested reservations have been created."
    prep_bins
  end

  def pay_with_cheque
    prep_results = prepare_cart_for_payment
    #
    # confirm_ready_to_proceed
    # cart_prep_results = CartServices::PrepCartForPayment.new(@cart_chassis).call
    #
    #
    # if !cart_prep_results[:good_to_go]
    #   flash[:alert] = "There was a problem with one or more of your items!"
    #   #CartServices::RecoverFailedProcessingItems.new(@cart_chassis, current_user).call
    #   #@cart.reload
    #   #TODO:  Maybe use the _payment_problem.html.erb partial here
    #   prep_bins
    #   redirect_to cart_path and return
    # end
    #
    # if cart_prep_results[:amount_to_charge] == 0
    #   flash[:notice] = "None of your items require payment."
    #   redirect_to reservations_path and return
    # end
    #return if !prep_results[:good_to_go]

    flash[:notice] = "Your requested reservations have been created. See your email for instructions on payment by cheque."

    # @cart_chassis.now_bin.status = Cart::AWAITING_CHEQUE
    # @cart_chassis.now_bin.save
    # @cart_chassis.now_bin = nil




    trigger_cart_waiting_for_cheque_payment_mailer(@cart_chassis.now_bin, @cart_chassis.subtotal_cents)

    @cart_chassis.update_to_waiting_for_check

    #prep_bins
    redirect_to reservations_path
  end

  #####REFACTORING_ENDS

  # ###############################
  # # Don't Know If I Need These: #
  # ###############################
  #
  # def edit_single_item
  #   # This will be for going into the reservation data, in theory
  #   # TODO: figure out if we need this.
  # end
  #
  # def update
  #   # TODO: Figure out if this, or some form of this, is actually necessary.
  # end
  #
  # def update_cart_info
  #   # TODO: figure out if this is necessary.
  #   # IF I ACTUALLY USE THIS it will be for shipping and billing-type stuff.
  # end

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

  # def build_new_cart_chassis
  #   binding.pry
  #   cart_for_now = locate_cart_for_now
  #   binding.pry
  #   cart_for_later = Cart.active_for_later.find_by(user_id: current_user.id)
  #   binding.pry
  #   @cart_chassis = CartChassis.new(now_bin: cart_for_now, later_bin: cart_for_later)
  # end
  #
  # def locate_cart_for_now
  #   binding.pry
  #
  #   now_cart = Cart.active_for_now.find_by(user_id:  current_user.id)
  #   now_cart ||= create_cart(with_status: FOR_NOW)
  # end
  #
  # def locate_cart_for_later
  #   binding.pry
  #   later_cart = Cart.active_for_later.find_by(user: current_user)
  #   later_cart ||= create_cart(with_status: FOR_LATER)
  # end

  def locate_target_item
    # defacto_cart = @cart if @cart.present?
    # defacto_cart ||= @cart_chassis

    # @target_item = helpers.locate_cart_item_with_cart(params[:id], defacto_cart)
    @target_item = CartItemsHelper.locate_cart_item(current_user, params[:id])
    if @target_item.blank?
      flash[:alert] = "Unable to recognize this item."
      prep_bins
      redirect_back(fallback_location: cart_path) and return
    end
  end

  # def locate_all_active_cart_items
  #   @now_cart_items = CartItemsHelper.cart_items_for_now(@cart)
  # end

  # def locate_all_cart_items_for_later
  #   @later_cart_items = CartItemsHelper.cart_items_for_later(@cart)
  # end
  #
  # def locate_all_cart_items
  #   @all_cart_items = @cart.cart_items
  # end

  # def locate_membership_offer_via_params
  #   #Being extracted to service object
  #   @our_offer = MembershipOffer.locate_active_offer_by_hashcode(params[:offer])
  #   if !@our_offer.present?
  #     flash[:error] = t("errors.offer_unavailable", offer: params[:offer])
  #     prep_bins
  #     redirect_back(fallback_location: memberships_path) and return
  #   end
  # end
  #
  # def generate_membership_beneficiary_from_params
  #   #Being extracted to service object.  Will be:
  #   # @our_beneficiary = ResolveCartItemBeneficiary.new(params).call
  #
  #   @our_beneficiary = theme_contact_class.new(our_contact_params)
  #   if @our_beneficiary.present?
  #     process_beneficiary_dob
  #     validate_beneficiary
  #   end
  # end

  # def single_item_is_available?
  #   @target_item.item_still_available?
  # end

  # def create_cart(with_status: PENDING)
  #   # Status PENDING is being deprecated.
  #   # Status FOR_NOW is for the part of the cart where active items go.
  #   # Status FOR_LATER is for the part of the cart where saved items go.
  #   cart = Cart.new status: with_status
  #   # current_user is a Devise helper.
  #   cart.user_id = User.find_by(id: current_user.id).id
  #   cart.active_from = Time.now
  #   if cart.save
  #     flash[:status] = :success
  #   else
  #     flash[:status] = :failure
  #     flash[:notice] = "We weren't able to fully create your shopping cart."
  #     flash[:messages] = cart.errors.messages
  #   end
  #   cart
  # end

    # TODO: Only allow a list of trusted parameters through.
  # def cart_params
  #   params.fetch(:cart, {})
  # end

  # def our_contact_params
  #   # Being extracted to service object. Will be eliminated.
  #   return params.require(theme_contact_param).permit(theme_contact_class.const_get("PERMITTED_PARAMS"))
  # end
  #
  # def validate_beneficiary
  #   # Being extracted to service object.  Will be eliminated.
  #   if !@our_beneficiary.valid?
  #     flash[:error] = @our_beneficiary.errors.full_messages.to_sentence(words_connector: ", and ").humanize.concat(".")
  #
  #     prep_bins
  #     redirect_back(fallback_location: root_path) and return
  #   else
  #     @our_beneficiary.save
  #   end
  # end
  #
  # def process_beneficiary_dob
  #   # Being extracted to service object.
  #   our_dob = DateOfBirthParamsHelper.generate_dob_from_params(params)
  #   if our_dob
  #     @our_beneficiary.date_of_birth = our_dob
  #   end
  # end

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

  # def confirm_ready_to_proceed
  #   # recovereds = CartServices::RecoverFailedProcessingItems.new(@cart_chassis, current_user).call
  #   # if recovereds > 0
  #   #   flash[:notice] = "#{recovereds} previously-added item(s) found.  Please review them before proceeding."
  #   #   prep_bins
  #   #   redirect_to cart_path and return
  #   # end
  #   if !now_items_confirmed_ready_for_payment?
  #     flash[:notice] = "Please review your cart before proceeding."
  #     prep_bins
  #     redirect_to cart_path and return
  #   end
  # end

  def trigger_cart_waiting_for_cheque_payment_mailer(cart, amount_outstanding)
    amt_owed = amount_outstanding.kind_of?(Integer) ? amount_outstanding : amount_outstanding.cents

    item_descs = CartContentsDescription.new(
      cart,
      with_layperson_uniq_id: true,
      for_email: true,
      force_full_contact_name: true
    ).describe_cart_contents

    PaymentMailer.cart_waiting_for_cheque(
      user: current_user,
      item_count: cart.cart_items.size,
      outstanding_amount: amt_owed,
      item_descriptions: item_descs,
      transaction_date: Time.now,
      cart_number: cart.id
    ).deliver_later
  end

  # def prep_bins
  #   @now_bin = nil
  #   @later_bin = nil
  #   if @cart.present?
  #     @cart.reload
  #     @now_bin = @cart.cart_items_for_now
  #     @later_bin = @cart.cart_items_for_later
  #     @shopping_cart = @cart
  #     @now_subtotal = @cart.subtotal_display
  #   elsif @cart_chassis.present?
  #     @cart_chassis.full_reload
  #     @now_bin = @cart_chassis.now_items
  #     @later_bin = @cart_chassis.later_items
  #     @now_subtotal = @cart_chassis.now_subtotal
  #   end
  # end


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
      #CartServices::RecoverFailedProcessingItems.new(@cart_chassis, current_user).call
      #@cart.reload
      #TODO:  Maybe use the _payment_problem.html.erb partial here
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
      redirect_to reservations_path, notice: "You've paid for this already." and return
    end
  end

  def prep_bins
    #TODO: Eliminate this temporary kludge
    get_cart_chassis
    @cart_chassis.full_reload
    @now_bin = @cart_chassis.now_items
    @later_bin = @cart_chassis.later_items
    @now_subtotal = @cart_chassis.purchase_subtotal
  end
end
