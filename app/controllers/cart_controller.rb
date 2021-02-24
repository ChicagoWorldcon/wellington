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

  before_action :require_nonsupport_login

  before_action :locate_cart
  before_action :locate_target_item, only: [:remove_single_item, :save_item_for_later, :move_item_to_cart, :verify_single_item_availability]

  before_action :verify_all_cart_contents, only: [:move_all_saved_items_to_cart]
  before_action :all_contents_confirmed_ready_for_payment?, only:[:submit_online_payment, :pay_with_cheque, :preview_purchase]

  before_action :locate_membership_offer_via_params, only: [:add_reservation_to_cart]
  before_action :generate_membership_beneficiary_from_params, only: [:add_reservation_to_cart]

  PENDING = "pending"
  MEMBERSHIP = "membership"

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
        render :cart and return
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
    render :cart
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
    render :cart
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
    render :cart
  end

  def remove_single_item
    if @target_item
      target_item_name = @target_item.item_display_name
      target_item_kind = @target_item.kind
      @target_item.destroy
      flash[:notice] = "#{@target_item_name} #{@target_item_kind} was successfully deleted"
    else
      flash[:alert] = "This item could not be removed from your cart."
      if @cart
        flash[:errors] = @cart.errors.messages
      end
    end
    @cart.reload
    render :cart
  end

  def save_item_for_later
    if @target_item
      @target_item.later = true
      if @target_item.save
        flash[:notice] = "Item successfully saved for later."
      end
    else
      flash[:notice] = "This item could not be saved for later."
      flash[:messages] = @cart.errors.messages
    end
    render :cart
  end

  def save_all_items_for_later
    CartItemsHelper.save_all_cart_items_for_later(@cart)
    @cart.reload
    if CartItemsHelper.cart_items_for_now(@cart).count == 0 && CartItemsHelper.cart_items_for_later(@cart).count > 0
        flash[:notice] = "All active items have now been saved for later."
      else
        flash[:notice] = "One or more items could not be saved for later"
    end
    render :cart
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
    render :cart
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
    render :cart
  end


  def verify_single_item_availability
    if @target_item.item_still_available?
      flash[:notice] = "Good news! #{@target_item.item_display_name} is still available."
    else
      flash[:alert] = "#{@target_item.item_display_name} is no longer available."
    end
    render :cart
  end

  def verify_all_items_availability
    verify_all_cart_contents
    render :cart
  end

  def edit_single_item
    # This will be for going into the reservation data, in theory
    # TODO: figure out if we need this.
  end

  def update
    # TODO: Figure out if this, or some form of this, is actually necessary.
    # respond_to do |format|
    #   if @cart.update(cart_params)
    #     format.html { redirect_to @cart, notice: 'Cart was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @cart }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @cart.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  def update_cart_info
    # IF I ACTUALLY USE THIS it will be for shipping and billing-type stuff.


    # [TODO] Find the cart order and then update
    # stuff from the params (presumably).
    # Then:
    # if @cart.save
    #   flash[:status] = :success
    #   flash[:result_text] = "Your order information has been successfully updated!"
    #   redirect_to cart_path and return
    # else
    #   flash[:status] = :failure
    #   flash[:result_text] = "We were unable to update your order information."
    #   flash[:messages] = @cart.errors.messages
    #   redirect_to cart_path and return
    # end
  end

  def submit_online_payment
    service = PayForCart.new(@cart)
    if service.call
      flash[:notice] = %{
        Thank you for your purchase!
      }
    end
    render :cart
  end

  def pay_with_cheque
  end

  private

  def require_nonsupport_login
    unless user_signed_in? && !support_signed_in?
      flash[:alert] = "You must be signed in to access the cart.  If you are a support user attempting to make personal purchases, please log in to your personal (nonsupport) account."
      redirect_to root_path
    end
  end

  def locate_cart
    @cart ||= Cart.find_by(user_id: current_user.id)
    @cart ||= create_cart
    if @cart.nil?
      flash[:status] = :failure
      flash[:notice] = "We were unable to find or create your shopping cart."
      redirect_to memberships_path
    end
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

  def create_cart
    # Status "pending" keeps downstream validations from rejecting the
    # cart for not having payment info, etc. Not sure if I'm going to have
    # those yet, but this preserves the option for now.
    if user_signed_in? && !support_signed_in?
      @cart = Cart.new status: PENDING
      # current_user is a Devise helper.
      @cart.user_id = User.find_by(id: current_user.id).id
      if @cart.save
        flash[:status] = :success
      else
        flash[:status] = :failure
        flash[:notice] = "We weren't able to create your shopping cart, so everything is now doomed."
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

  def all_contents_confirmed_ready_for_payment?
    confirmed = true
    if !CartItemesHelper.cart_contents_ready_for_payment?(@cart)
      flash[:alert] = "there is a problem with one or more of your items."
      confirmed = false
    end
    confirmed
  end
end
