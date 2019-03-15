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
  def index
  end

  def new
    @purchase = current_user.purchases.find(params.require(:purchaseId))

    if @purchase.paid?
      redirect_to purchases_path, notice: "You've paid for this #{@purchase.membership} membership"
      return
    end

    @membership = @purchase.membership
    @outstanding_amount = AmountOwedForPurchase.new(@purchase).amount_owed

    price_steps = PaymentAmountOptions.new(@outstanding_amount).amounts

    @price_options = price_steps.reverse.map do |price|
      [format_nzd(price), price]
    end
  end

  def create
    @purchase = current_user.purchases.find(params[:purchaseId])
    @charge_amount = params[:amount].to_i

    outstanding_amount = AmountOwedForPurchase.new(@purchase).amount_owed

    allowed_charge_amounts = PaymentAmountOptions.new(outstanding_amount).amounts
    if !allowed_charge_amounts.include?(@charge_amount)
      flash[:error] =  "Amount must be one of the provided payment amounts"
      redirect_to new_charge_path(purchaseId: @purchase.id)
      return
    end

    service = ChargeCustomer.new(@purchase, current_user, params[:stripeToken], outstanding_amount, charge_amount: @charge_amount)

    charge_successful = service.call
    if !charge_successful
      flash[:error] = service.error_message
      redirect_to new_charge_path(purchaseId: @purchase.id)
      return
    end

    if @purchase.charges.successful.size == 1
      PaymentMailer.new_member(user: current_user, purchase: @purchase, charge: service.charge, outstanding_amount: outstanding_amount).deliver_later
    else
      PaymentMailer.installment_payment(user: current_user, purchase: @purchase, charge: service.charge, outstanding_amount: outstanding_amount).deliver_later
    end

    message = "Thank you for your #{helpers.number_to_currency(@charge_amount / 100)} payment"
    (message += ". Your #{@purchase.membership} membership has been fully paid for.") if @purchase.paid?
    redirect_to purchases_path, notice: message
  end

  private

  def format_nzd(price)
    "#{helpers.number_to_currency(price / 100)} NZD"
  end
end
