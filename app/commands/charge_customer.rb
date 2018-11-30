# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
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

# CreatePayment charges a customer and creates a charge record. Truthy returns mean the charge succeeded, but false
# means the charge failed. Check #errors for failure details.
class ChargeCustomer
  STRIPE_CHARGE_DESCRIPTION = "CoNZealand Purchase"
  CURRENCY = "nzd"

  attr_reader :purchase, :user, :token, :charge_amount

  def initialize(purchase, user, token, charge_amount: nil)
    @purchase = purchase
    @user = user
    @token = token
    @charge_amount = charge_amount || amount_owed
  end

  def call
    @charge = Charge.stripe.new(
      user: user,
      purchase: purchase,
      stripe_id: token,
      amount: charge_amount,
    )

    check_charge_amount
    create_stripe_customer unless errors.any?
    create_stripe_charge unless errors.any?

    if errors.any?
      @charge.state = Charge::STATE_FAILED
      @charge.comment = error_message
    elsif !@stripe_charge[:paid]
      @charge.state = Charge::STATE_FAILED
    else
      @charge.state = Charge::STATE_SUCCESSFUL
    end

    if @stripe_charge.present?
      @charge.stripe_id       = @stripe_charge[:id]
      @charge.amount          = @stripe_charge[:amount]
      @charge.comment         = @stripe_charge[:description]
      @charge.stripe_response = json_to_hash(@stripe_charge.to_json)
    end

    purchase.transaction do
      @charge.save!
      if fully_paid?
        purchase.update!(state: Purchase::PAID)
      else
        purchase.update!(state: Purchase::INSTALLMENT)
      end
    end

    return @charge.state == Charge::STATE_SUCCESSFUL
  end

  def error_message
    errors.to_sentence
  end

  def errors
    @errors ||= []
  end

  private

  def check_charge_amount
    if charge_amount > amount_owed
      errors << "refusing to overpay for purchase"
    end
  end

  def create_stripe_customer
    @stripe_customer = Stripe::Customer.create(email: user.email, source: token)
  rescue Stripe::StripeError => e
    errors << e.message
    @charge.stripe_response = json_to_hash(e.response)
    @charge.comment = "failed to create Stripe::Customer - #{e.message}"
  end

  def create_stripe_charge
    @stripe_charge = Stripe::Charge.create(
      description: STRIPE_CHARGE_DESCRIPTION,
      currency: CURRENCY,
      customer: @stripe_customer.id,
      amount: charge_amount,
    )
  rescue Stripe::StripeError => e
    errors << e.message
    @charge.stripe_response = json_to_hash(e.response)
    @charge.comment =  "failed to create Stripe::Charge - #{e.message}"
  end

  def json_to_hash(obj)
    JSON.parse(obj.to_json)
  rescue
    {}
  end

  def fully_paid?
    amount_owed <= 0
  end

  def amount_owed
    membership_cost = purchase.membership.price
    paid_so_far = purchase.charges.successful.sum(:amount)
    membership_cost - paid_so_far
  end
end
