# frozen_string_literal: true

# Copyright 2019 AJ Esler
# Copyright 2019 Matthew B. Gray
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

  before_action :lookup_reservation!

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

  def create
    charge_amount = Money.new(params[:amount].to_i)

    outstanding_before_charge = AmountOwedForReservation.new(@reservation).amount_owed

    allowed_charge_amounts = PaymentAmountOptions.new(outstanding_before_charge).amounts
    if !charge_amount.in?(allowed_charge_amounts)
      flash[:error] = "Amount must be one of the provided payment amounts"
      redirect_to new_reservation_charge_path
      return
    end

    service = Money::StartStripeCheckout.new(
      reservation: @reservation,
      user: current_user,
      amount_owed: outstanding_before_charge,
      charge_amount: charge_amount,
      success_url: stripe_checkout_success_reservation_charges_url,
      cancel_url: stripe_checkout_cancel_reservation_charges_url,
    )

    checkout_started = service.call
    if !checkout_started
      flash[:error] = service.error_message
      redirect_to new_reservation_charge_path
      return
    end

    redirect_to service.checkout_url
  end

  def stripe_checkout_success
    message = "Thank you for your payment"
    if @reservation.paid?
      message += ". Your #{@reservation.membership} membership has been paid for."
    else
      message += ". It may take up to an hour for your payment to be processed. Please contact support if you experience issues."
    end
    
    redirect_to reservations_path, notice: message
  end

  def stripe_checkout_cancel
    redirect_to new_reservation_charge_path(@reservation)
  end

end
