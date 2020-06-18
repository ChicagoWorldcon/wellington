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
  # These are order-dependent; the single depends on all the user ones
  before_action :lookup_user_reservations!
  before_action :lookup_single_reservation!

  PendingCharges = Struct.new(:reservation, :membership, :outstanding_amount, :price_options)

  def new
    unpaid_reservations = @reservations.reject{ |r| r.paid? }
    if unpaid_reservations.empty?
      return redirect_to reservations_path, notice: "You've paid for all your reservations"
    end

    @pending_charges = @reservations.map do |reservation|
      owed = AmountOwedForReservation.new(reservation).amount_owed
      price_steps = PaymentAmountOptions.new(owed).amounts

      PendingCharges.new(
        reservation,
        reservation.membership,
        owed,
        price_steps.reverse.map do |price|
          [price.format, price.cents]
        end
      )
    end

    # some special handling for a charge for a single reservation
    if @reservation.present?
      @pending_charge = @pending_charges[0]
      render "new_for_reservation"
    end

    # @membership = @reservation.membership
    # @outstanding_amount = AmountOwedForReservation.new(@reservation).amount_owed

    # price_steps = PaymentAmountOptions.new(@outstanding_amount).amounts

    # @price_options = price_steps.reverse.map do |price|
    #   [price.format, price.cents]
    # end
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

    trigger_payment_mailer(service.charge, outstanding_before_charge, charge_amount)

    message = "Thank you for your #{charge_amount.format} payment"
    (message += ". Your #{@reservation.membership} membership has been paid for.") if @reservation.paid?

    redirect_to reservations_path, notice: message
  end

  private

  def lookup_single_reservation!
    if params.has_key?(:reservation_id) or params.has_key?(:id)
      @reservation = @reservations.find(params[:reservation_id] || params[:id])
    else
      @reservation = nil
    end
  end

  def lookup_user_reservations!
    visible_reservations = Reservation.joins(:user)

    if !support_signed_in?
      visible_reservations = visible_reservations.where(users: { id: current_user })
    end
    @reservations = visible_reservations
  end

  def trigger_payment_mailer(charge, outstanding_before_charge, charge_amount)
    if charge.reservation.instalment?
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
