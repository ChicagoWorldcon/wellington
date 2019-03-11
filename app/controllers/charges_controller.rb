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
      redirect_to purchase_path(@purchase), notice: "This membership has already been paid for"
      return
    end

    @membership = @purchase.membership
    @outstanding_amount = AmountOwedForPurchase.new(@purchase).amount_owed

    price_steps = PaymentAmountOptions.new(@amount_owed).amounts

    @price_options = price_steps.map { |price| [helpers.number_to_currency(price / 100), price] }
  end

  def create
    @purchase = current_user.purchases.find(params[:purchaseId])
    @charge_amount = params[:amount].to_i

    amount_owed = AmountOwedForPurchase.new(@purchase).amount_owed

    service = ChargeCustomer.new(@purchase, current_user, params[:stripeToken], amount_owed, charge_amount: @charge_amount)

    charge_successful = service.call
    if charge_successful
      PaymentMailer.new_member(user: current_user, purchase: @purchase, charge: service.charge).deliver_later

      # TODO: different message if membership is fully paid
      message = "Thank you for your #{helpers.number_to_currency(@charge_amount / 100)} payment towards this membership"
      redirect_to(purchases_path, notice: message)
    else
      flash[:error] = service.error_message
      redirect_to new_charge_path(purchaseId: @purchase.id)
    end
  end
end
