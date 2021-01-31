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
  PENDING = "pending"
  MEMBERSHIP = "membership"

  def show
    if user_signed_in? && !support_signed_in?
      @cart = locate_cart
      render :cart
    else
      flash[:alert] = "You must be signed in to access the cart."
      redirect_to root_path
    end
  end

  def add_reservation_to_cart
    @cart = locate_cart
    binding.pry
    our_offer = CartItemsHelper.locate_offer(params[:offer])
    binding.pry
    @our_beneficiary = Claim.contact_strategy.new(our_contact_params)
    process_beneficiary_dob
    validate_beneficiary
    binding.pry
    if (our_offer.present? && @our_beneficiary.present?)
      binding.pry
      @our_cart_item = CartItem.create membership_id: our_offer.membership.id, item_name: our_offer.membership.name, item_price_cents: our_offer.membership.price_cents, cart_id: @cart.id,
      chicago_contact_id: @our_beneficiary.id,
      kind: MEMBERSHIP,
      later: false
      if @our_cart_item.save
        flash[:status] = :success
        flash[:notice] = "Membership successfully added to cart."
        binding.pry
        redirect_to cart_path and return
      end
    end
    flash[:status] = :failure
    flash[:notice] = "This membership could not be added to your cart."
    flash[:messages] = @cart.errors.messages
    binding.pry
    redirect_to new_reservation_path
  end

  def update_cart_info
    @cart = locate_cart
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
    @cart = locate_cart
    #TODO
  end

  def pay_with_cheque
    @cart = locate_cart
    #TODO
  end

  def destroy
    # This empties the cart of all items, both active and saved.
    @cart = locate_cart
    if @cart.nil?
      flash[:status] = :failure
      flash[:result_text] = "Unable to remove the items from your cart."
      redirect_to cart_path and return
    end
    if @cart.cart_items.count > 0
      @cart.cart_items.each do |cart_item|
        cart_item.destroy
      end
    end
    if @cart.cart_items.count == 0
      flash[:status] = :success
      flash[:notice] = "Your cart has been emptied."
    else
      flash[:status] = :failure
      flash[:notice] = "Your cart could not be fully emptied."
    end
    redirect_to cart_path
  end

  def destroy_active
    @cart = locate_cart
    binding.pry
    if @cart.nil?
      binding.pry
      flash[:status] = :failure
      flash[:notice] = "Unable to find cart."
      redirect_to cart_path and return
    end
    now_items = CartItemsHelper.cart_items_for_now(@cart)
    binding.pry
    if now_items.count > 0
      binding.pry
      now_items.each do |now_item|
        now_item.destroy
      end
    end
    if CartItemsHelper.cart_items_for_now(@cart).count == 0
      binding.pry
      flash[:status] = :success
      flash[:notice] = "Active cart successfully emptied!"
    else
      binding.pry
      flash[:status] = :failure
      flash[:notice] = "One or more items could not be deleted."
    end
    binding.pry
    redirect_to cart_path
  end

  def destroy_saved
    @cart = locate_cart
    binding.pry
    if @cart.nil?
      binding.pry
      flash[:status] = :failure
      flash[:result_text] = "Unable to find cart."
      redirect_to cart_path and return
    end
    later_items = CartItemsHelper.cart_items_for_later(@cart)
    binding.pry
    if later_items.count > 0
      binding.pry
      later_items.each do |later_item|
        later_item.destroy
      end
    end
    if CartItemsHelper.cart_items_for_later(@cart).count == 0
      binding.pry
      flash[:status] = :success
      flash[:notice] = "Saved items successfully cleared!"
    else
      binding.pry
      flash[:status] = :failure
      flash[:result_text] = "One or more items could not be deleted."
    end
    binding.pry
    redirect_to cart_path
  end

  def remove_single_item
    binding.pry
    @cart = locate_cart
    @target_item = CartItem.find(params[:id])
    if @target_item && @cart && (@target_item.cart_id == @cart.id)
      @target_item_name = @target_item.item_name
      @target_item_kind = @target_item.kind
      @target_item.destroy
      flash[:status] = :success
      flash[:notice] = "#{@target_item_name} #{@target_item_kind} successfully deleted"
      binding.pry
    else
      flash[:status] = :failure
      flash[:notice] = "This item could not be removed from your cart."
      if @cart
        flash[:errors] = @cart.errors.messages
      end
      if @target_item
        flash[:errors] = @target_item.errors.messages
      end
    end
    redirect_to cart_path
  end

  def save_item_for_later
    binding.pry
    @cart = locate_cart
    target_item = CartItem.find(params[:id])
    target_item.later = true
    if target_item.save
      flash[:status] = :success
      flash[:notice] = "Item successfully saved for later."
      binding.pry
    else
      flash[:status] = :failure
      flash[:notice] = "This item could not be saved for later."
      flash[:messages] = @cart.errors.messages
      binding.pry
    end
    binding.pry
    redirect_to cart_path
  end

  def save_all_items_for_later
    binding.pry
    @cart = locate_cart
    now_items = CartItemsHelper.cart_items_for_now(@cart)
    now_items.each do |item|
      item.now = false;
      item.save
      # TODO: Add appropriate flash messages
    end
    redirect_to cart_path
  end

  def move_item_to_cart
    binding.pry
    @cart = locate_cart
    target_item = CartItem.find(params[:id])
    target_item.later = false
    binding.pry
    if target_item.save
      binding.pry
      flash[:status] = :success
      flash[:notice] = "Item successfully moved to cart."
      binding.pry
    else
      #TODO: See if we actually need to have the cat location doubled like this.
      flash[:status] = :failure
      flash[:notice] = "This item could not be moved to the cart."
      flash[:messages] = @cart.errors.messages
      binding.pry
    end
    binding.pry
    redirect_to cart_path
  end

  def move_all_saved_items_to_cart
    binding.pry
    @cart = locate_cart
    later_items = CartItemsHelper.cart_items_for_later(@cart)
    later_items.each do |item|
      item.later = false;
      item.save
      # TODO: Add appropriate flash messages
    end
    redirect_to cart_path
  end


  def verify_single_item_availability
    binding.pry
    target_item = CartItem.find(params[:id])
    target_item.confirm_item_availability
    if !target_item.confirm_item_availability
      flash[:notice] = "#{target_item.item_name} is no longer available."
    else
      flash[:notice] = "Good news! #{target_item.item_name} is still available."
    end
    redirect_to cart_path
  end

  def verify_all_items_availability
    @cart = locate_cart
    if !CartItemsHelper.verify_availability_of_cart_contents(@cart)
      flash[:notice] = "One or more of your items is no longer available."
    end
    redirect_to cart_path
  end

  def edit_single_item
    # This will be for going into the reservation data, in theory
    # TODO: figure out if we need this.
  end

  def update
    # TODO: Figure out if this, or some form of this, is actually necessary.
    respond_to do |format|
      if @cart.update(cart_params)
        format.html { redirect_to @cart, notice: 'Cart was successfully updated.' }
        format.json { render :show, status: :ok, location: @cart }
      else
        format.html { render :edit }
        format.json { render json: @cart.errors, status: :unprocessable_entity }
      end
    end
  end



  # DELETE /carts/1
  # DELETE /carts/1.json
  # def destroy
  #   @cart_contents.destroy
  #   respond_to do |format|
  #     format.html { redirect_to carts_url, notice: 'Cart was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private

  def locate_cart
    @cart ||= Cart.find_by(user_id: current_user.id)
    return @cart ||= create_cart
  end

  def cart_item_membership_id
    target_item = CartItem.find(params[:id])
    if target_item.present?
      target_item.membership_id
    else
      -1
    end
  end

  # Use callbacks to share common setup or constraints between actions.
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
        flash[:notice] = "I don't know if we need this but welcome to your Chicon 8 shopping cart!"
      else
        flash[:status] = :failure
        flash[:notice] = "We weren't able to create your shopping cart, so everything is now doomed."
        flash[:messages] = @cart.errors.messages
      end
      return @cart
    else
      return
    end
  end

    # Only allow a list of trusted parameters through.
  # def cart_params
  #   params.fetch(:cart, {})
  # end

  def process_beneficiary_dob
    binding.pry
    if dob_params_present?
      @our_beneficiary.date_of_birth = convert_dateselect_params_to_date
    end
  end

  def validate_beneficiary
    if !@our_beneficiary.valid?
      flash[:error] = @our_beneficiary.errors.full_messages.to_sentence(words_connector: ", and ").humanize.concat(".")
      # TODO: Make sure this is what you want to render.
      render "/reservations/new"
      return
    else
      @our_beneficiary.save
    end
  end

  # THE FOLLOWING THREE METHODS DUPLICATE METHODS IN RESERVATION CONTROLLER
  def our_contact_params
    return params.require(theme_contact_param).permit(theme_contact_class.const_get("PERMITTED_PARAMS"))
  end

  def convert_dateselect_params_to_date
    key1 = "dob_array(1i)"
    key2 = "dob_array(2i)"
    key3 = "dob_array(3i)"
    Date.new(params[theme_contact_param][key1].to_i, params[theme_contact_param][key2].to_i, params[theme_contact_param][key3].to_i)
  end

  def dob_params_present?
    dob_key_1 = "dob_array(1i)"
    return params[theme_contact_param].key?(dob_key_1)
  end
end
