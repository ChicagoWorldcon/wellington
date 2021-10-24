# frozen_string_literal: true

# Copyright 2019 AJ Esler
# Copyright 2019 Matthew B. Gray
# Copuright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");
#
# 23-Oct-21 Cloned from charges_controller.rb

# Test cards are here: https://stripe.com/docs/testing
class SiteChargesController < ApplicationController

  before_action :lookup_reservation!

  def new
    # if @reservation.paid?
    #   redirect_to reservations_path, notice: "You've paid for this #{@reservation.membership} membership"
    #   return
    # end

    @membership = @reservation.membership
    @outstanding_amount = AmountOwedForReservation.new(@reservation).amount_owed

    price_steps = PaymentAmountOptions.new(@outstanding_amount).amounts

    @price_options = price_steps.reverse.map do |price|
      [price.format, price.cents]
    end
  end

  def create
    charge_amount = Money.new(5000)                   ################ TODO change to variable amount

#    outstanding_before_charge = AmountOwedForReservation.new(@reservation).amount_owed

#    allowed_charge_amounts = PaymentAmountOptions.new(outstanding_before_charge).amounts
#    if !charge_amount.in?(allowed_charge_amounts)
#      flash[:error] = "Amount must be one of the provided payment amounts"
#      redirect_to new_reservation_charge_path
#      return
#    end

    service = Money::StartStripeCheckout.new(
      reservation: @reservation,
      user: current_user,
      amount_owed: charge_amount,
      charge_amount: charge_amount,
      success_url: stripe_checkout_success_reservation_site_charges_url,
      cancel_url: stripe_checkout_cancel_reservation_site_charges_url,
      site: true                                                #############################################
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
    if @reservation.token?                                     ############### Fix what to check for
      message += ". Your Site Selection has been paid for."
    else
      message += ". It may take up to an hour for your payment to be processed. Please contact support if you experience issues."
    end
    
    redirect_to reservations_path, notice: message
  end

  def stripe_checkout_cancel
    redirect_to new_reservation_site_charge_path(@reservation)
  end

end
