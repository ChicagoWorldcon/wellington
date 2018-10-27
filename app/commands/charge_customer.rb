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

  attr_reader :membership, :user, :token, :charge_amount

  def initialize(membership, user, token, charge_amount: nil)
    @membership = membership
    @user = user
    @token = token
    @charge_amount = charge_amount || membership.worth
  end

  def call
    @charge = Charge.new(
      user: user,
      membership: membership,
      stripe_id: token,
      cost: charge_amount,
    )

    check_charge_amount
    create_stripe_customer unless errors.any?
    create_stripe_charge unless errors.any?

    if errors.any?
      @charge.state = Charge::FAILED
      @charge.comment = error_message
    elsif !@stripe_charge[:paid]
      @charge.state = Charge::FAILED
    else
      @charge.state = Charge::SUCCEEDED
    end

    if @stripe_charge.present?
      @charge.stripe_id       = @stripe_charge[:id]
      @charge.cost            = @stripe_charge[:amount]
      @charge.comment         = @stripe_charge[:description]
      @charge.stripe_response = json_to_hash(@stripe_charge.to_json)
    end

    membership.transaction do
      @charge.save!
      if fully_paid?
        membership.update!(state: Membership::ACTIVE)
      else
        membership.update!(state: Membership::INSTALLMENT)
      end
    end

    return @charge.state == Charge::SUCCEEDED
  end

  def error_message
    errors.to_sentence
  end

  def errors
    @errors ||= []
  end

  private

  def check_charge_amount
    if charge_amount > membership.worth
      errors << "refusing to overpay for membership"
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
    membership.charges.succeeded.sum(:cost) >= membership.worth
  end
end
