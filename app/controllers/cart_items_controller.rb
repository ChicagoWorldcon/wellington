# frozen_string_literal: true
#
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


class CartItemsController < ApplicationController
  include ThemeConcern
  before_action :lookup_offer, only: [:create_reservation_item]
  before_action :reservation_item_recipient, only: [:create_reservation_item]
  # before_action :set_cart_item, only: [:show, :edit, :update, :destroy]

  MEMBERSHIP = "membership"
  # DONATION = "donation"
  # UPGRADE = "upgrade"

  # GET /cart_items
  # GET /cart_items.json
  def index
    @cart_items = CartItem.all
  end

  def index_current_cart_items(our_cart_id)
    @cart_items = CartItem.find_by(cart_id: our_cart_id)
  end

  # GET /cart_items/1
  # GET /cart_items/1.json
  def show
  end

  # GET /cart_items/1/edit
  def edit
  end

  def edit_item_membership
  end

  def edit_item_recipient
  end

  def update_item_membership
  end

  def update_item_recipient
  end

  def move_to_cart
  end

  def verify_availability
  end

  def create_reservation_item
    @cart_item = CartItem.new
    @cart_item.type = MEMBERSHIP
    if !@contact.valid?
      flash[:error] = @contact.errors.full_messages.to_sentence(words_connector: ", and ").humanize.concat(".")
      #TODO:  Rethink what you want to render here.
      redirect_to "/reservations/new" and return
    end
    @cart_item.chicago_contact = @contact
    @cart_item.membership = @my_offer
    render :cart
  end

  def create
    @cart_item = CartItem.new(cart_item_params)

    respond_to do |format|
      if @cart_item.save
        format.html { redirect_to @cart_item, notice: 'Cart item was successfully created.' }
        format.json { render :show, status: :created, location: @cart_item }
      else
        format.html { render :new }
        format.json { render json: @cart_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @cart_item.update(cart_item_params)
        format.html { redirect_to @cart_item, notice: 'Cart item was successfully updated.' }
        format.json { render :show, status: :ok, location: @cart_item }
      else
        format.html { render :edit }
        format.json { render json: @cart_item.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @cart_item.destroy
    respond_to do |format|
      format.html { redirect_to cart_items_url, notice: 'Cart item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def reservation_item_recipient
    @contact = contact_model.new(contact_params)
    if dob_params_present?
      @contact.date_of_birth = convert_dateselect_params_to_date
    end
    @contact
  end

  def set_cart_item
    @cart_item = CartItem.find(params[:id])
  end

  # TODO: Only allow a list of trusted parameters through.
  #def cart_item_params
    # Thinking: Item-type, Item-id, hrrrm.
    #params.fetch(:cart_item, {})
#  end

  #TODO:  **ALL** of the stuff below is duplicated from the Reservation controller.  This stuff needs to be extracted to a helper or a concern or something, because THIS IS NOT OKAY.  (I know I'm the one who put it here, but it's meant to be temporary. If there's a PR and this is still here, then something has gone wrong. --VEG)

  def contact_params
    return params.require(theme_contact_param).permit(theme_contact_class.const_get("PERMITTED_PARAMS"))
  end

  def contact_model
    Claim.contact_strategy
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

  def lookup_offer
    @my_offer = MembershipOffer.options.find do |offer|
      offer.hash == params[:offer]
    end

    if !@my_offer.present?
      #TODO:  Do something better than what happens below.
      flash[:error] = t("errors.offer_unavailable", offer: params[:offer])
      redirect_to memberships_path
    end
  end
end
