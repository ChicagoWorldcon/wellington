# frozen_string_literal: true
#
# Copyright 2019 AJ Esler
# Copyright 2019 Matthew B. Gray
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

# Test cards are here: https://stripe.com/docs/testing
class ChargesController < ApplicationController
  before_action :lookup_reservation!, except: [:new_group_charge, :create_group_charge, :group_charge_confirmation]

  def new
    if @reservation.paid?
      redirect_to reservations_path, notice: "You've paid for this #{@reservation.membership} membership"
      return
    end

    @membership = @reservation.membership
    @outstanding_amount = AmountOwedForReservation.new(@reservation).amount_owed

    price_steps = PaymentAmountOptions.new(@outstanding_amount).amounts

    @price_options = price_steps.reverse.map do |price|
      [price.format, price.cents]
    end
  end

  def new_group_charge
    @cart_for_charge = Cart.find_by(id: params[:processing_cart])
    @amount_to_charge = params[:total_cents]
    @items_to_buy = @cart_for_charge.cart_items

    if @amount_to_charge > 0 && !@cart_for_charge.cart_items.empty
      render :new_group_charge and return
    else
      redirect_to reservations_path, notice: "There is no balancing owing for any of your items"
      return
    end
  end

  def create
    charge_amount = Money.new(params[:amount].to_i)

    outstanding_before_charge = AmountOwedForReservation.new(@reservation).amount_owed

    allowed_charge_amounts = PaymentAmountOptions.new(outstanding_before_charge).amounts
    if !charge_amount.in?(allowed_charge_amounts)
      flash[:error] = "Amount must be one of the provided payment amounts"
      redirect_to new_reservation_charge_path
      return
    end

    service = Money::ChargeCustomer.new(
      @reservation,
      current_user,
      params[:stripeToken],
      outstanding_before_charge,
      charge_amount: charge_amount,
    )

    charge_successful = service.call
    if !charge_successful
      flash[:error] = service.error_message
      redirect_to new_reservation_charge_path
      return
    end

    trigger_reservation_payment_mailer(service.charge, outstanding_before_charge, charge_amount)

    message = "Thank you for your #{charge_amount.format} payment"
    (message += ". Your #{@reservation.membership} membership has been paid for.") if @reservation.paid?

    redirect_to reservations_path, notice: message
  end

  def create_group_charge
    charge_amount = Money.new(params[:amount].to_i)
    @processing_cart = Cart.find_by(id: params[:buyable])

    successful = ActiveRecord::Base.transaction(joinable: false, requires_new: true) do

      service = Money::ChargeCustomer.new(
        @processing_cart,
        current_user,
        params[:stripeToken],
        charge_amount,
        charge_amount: charge_amount,
      )

      charge_succeeded = service.call

      if !charge_succeeded
        flash[:error] = service.error_message
        raise ActiveRecord::Rollback
      else
        CartItemsHelper.post_payment_housekeeping(@processing_cart, true)
        trigger_cart_payment_mailer(service.charge, charge_amount, @processing_cart)
      end

      charge_succeeded
    end

    if !successful
      redirect_to cart_preview_online_purchase_path and return
    end

    redirect_to group_charge_confirmation_path(processed_cart: @processing_cart, charge: @processing_cart.charges.order("created_at").last)
  end

  def group_charge_confirmation
    @amount_charged = Money.new(Charge.find_by(id: params[:charge]).amount_cents).format(with_currency: true)
    @processed_cart = Cart.find_by(id: params[:processed_cart])
  end

  private

  def trigger_cart_payment_mailer(charge, charge_amount, processing_cart)

    item_description_array = CartContentsDescription.new(
      processing_cart,
      for_email: true,
      force_full_contact_name: true
    ).describe_cart_contents

    PaymentMailer.cart_paid(
      user: current_user,
      charge: charge,
      amount: charge_amount,
      item_count: processing_cart.cart_items.size,
      item_descriptions: item_description_array,
      purchase_date: processing_cart.active_to,
      cart_number: processing_cart.id
    )
  end

  def trigger_reservation_payment_mailer(charge, outstanding_before_charge, charge_amount)
    if charge.buyable.instalment?
      PaymentMailer.instalment(
        user: current_user,
        charge: charge,
        outstanding_amount: (outstanding_before_charge - charge_amount).format(with_currency: true)
      ).deliver_later
    else
      PaymentMailer.paid(
        user: current_user,
        charge: charge,
      ).deliver_later
    end
  end
end
