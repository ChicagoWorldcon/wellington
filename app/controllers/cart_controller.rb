# frozen_string_literal: true

# Copyright 2020 Victoria Garcia
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

  def show
    if user_signed_in? && !support_signed_in?
      @cart = locate_cart
      render :cart
    else
      flash[:alert] = "You must be signed in to access the cart."
      redirect_to root_path
    end
  end

  def add_to_cart
    @cart = locate_cart

    # then put in the actual adding stuff
    # make sure that 'cart_path' is actually right.
    redirect_to cart_path
  end

  def update_cart_info
    @cart = locate_cart
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
  end

  def submit_check_payment
    @cart = locate_cart
  end

  def destroy
    @cart = locate_cart
    # First, find the cart-order
    # @cart = Order.find_by(id: session[:cart_order_id])
    # if @cart.nil?
    #   flash[:status] = :failure
    #   flash[:result_text] = "Unable to remove the items from your cart."
    #   redirect_to cart_path and return
    # end
    # if @cart.cart_items.count > 0
    #   @cart.cart_items.each do |cart_item|
    #     cart_item.destroy
    #   end
    # else
    #   flash[:status] = :failure
    #   flash[:result_text] = "Your cart was already empty!"
    # end
    # redirect_to cart_path
  end

  def remove_single_item
    # First, find the cart contents by whatever means
    # @cart_item = CartItem.find_by(id: params[:id])
    # if @cart_item && @cart && (@ocart_item.order_id == @cart.id)
    #   @cart_item_name = @cart_item.name
    #   @cart_item.destroy
    #   flash[:status] = :success
    #   flash[:result_text] = "#{@cart_item_name} removed from your cart!"
    # else
    #   flash[:status] = :failure
    #   flash[:result_text] = "Unable to remove the items from your cart."
    #   if @cart
    #     flash[:errors] = @cart.errors.messages
    #   end
    #   if @cart_item
    #     flash[:errors] = @cart_item.errors.messages
    #   end
    #   redirect_to cart_path and return
    # end
    # if !(@cart.cart_items.count > 0)
    #   render :empty_cart and return
    # else
    #   redirect_to cart_path
    # end
  end

  def save_item_for_later
  end

  def move_item_to_cart
  end

  def verify_single_item_availability
  end

  def edit_single_item
    # This will be for going into the reservation data
  end

  def update
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

  def verify_cart_contents
    @cart = locate_cart
  end

  def subtotal_cart
    @cart = locate_cart
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

  # Use callbacks to share common setup or constraints between actions.
  def create_cart
    # Status "pending" keeps downstream validations from rejecting the
    # cart for not having payment info, etc. Not sure if I'm going to have
    # those yet, but this preserves the option for now.
    if user_signed_in? && !support_signed_in?
      @cart = Cart.new status: PENDING
      # current_user is a Devise helper.
      binding.pry
      @cart.user_id = User.find_by(id: current_user.id).id
      if @cart.save
        binding.pry
        flash[:status] = :success
        flash[:notice] = "I don't know if we need this but welcome to your Chicon 8 shopping cart!"
      else
        binding.pry
        flash[:status] = :failure
        flash[:notice] = "We weren't able to create your shopping cart, so everything is now doomed."
        flash[:messages] = @cart.errors.messages
      end
      binding.pry
      return @cart
    else
      return
    end
  end

    # Only allow a list of trusted parameters through.
  # def cart_params
  #   params.fetch(:cart, {})
  # end
end
