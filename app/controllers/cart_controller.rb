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

  def access_cart
      # TODO: This needs a mechanism for checking to see if the things in the cart
      # have changed price, are still available, etc.
      render "reservations/cart"
  end

  def add_to_cart
    if @cart.nil?
      @cart = create_cart
    end
    # then put in the actual adding stuff
    # make sure that 'cart_path' is actually right.
    redirect_to cart_path
  end

  def update_cart_info
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
  end

  def submit_check_payment
  end

  def destroy
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

  def edit_single_item
    # This will be for going into the reservation data
  end





  # GET /carts/new
  def new
    @cart = Cart.new
  end

  def create_cart



    # VEG note: Not sure if we need the Pending thing, but it's what we did
    # on Betsy.  TODO: see if `status: pending` actually gets used for anything.
    # @cart = CartOrder.new status: "pending"
    #
    # respond_to do |format|
    #   if @cart.save
    #     format.html { redirect_to @cart, notice: 'Cart was successfully created.' }
    #     format.json { render :show, status: :created, location: @cart }
    #   else
    #     format.html { render :new }
    #     format.json { render json: @cart.errors, status: :unprocessable_entity }
    #   end
    # end
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

  # DELETE /carts/1
  # DELETE /carts/1.json
  def destroy
    @cart.destroy
    respond_to do |format|
      format.html { redirect_to carts_url, notice: 'Cart was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def create_cart
    # Status "pending" keeps downstream validations from rejecting the
    # CartOrder for not having payment info, etc.
    @cartContents = CartOrder.new status: "pending"
    # current_user is a Devise helper.
    session[:cart_order_id] = current_user.id
    if @cartOrder.save
      flash[:status] = :success
      flash[:result_text] = "I don't know if we need this but welcome to Chicon 8!"
    else
      flash[:status] = :failure
      flash[:result_text] = "We weren't able to create your shopping cart."
      flash[:messages] = @cartOrder.errors.messages
    end
    return @cartOrder
  end

    # Only allow a list of trusted parameters through.
  def cart_params
    params.fetch(:cart, {})
  end

  #Initalize Cart Session
  # def initialize_cart_session
  #   @session = session
  #   @session[:cart] ||= {}
  # end
end
