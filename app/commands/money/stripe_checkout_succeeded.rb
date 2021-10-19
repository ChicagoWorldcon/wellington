# frozen_string_literal: true

# Copyright 2021 DisCon III
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

# Money::StripeCheckoutSucceeded updates the Charge record associated with that checkout session to indicate that the payment succeeded.
# Truthy returns mean that everything updated correctly, otherwise check #errors for failure details.
class Money::StripeCheckoutSucceeded
  attr_reader :charge, :stripe_checkout_session

  def initialize(charge:, stripe_checkout_session:)
    @charge = charge
    @stripe_checkout_session = stripe_checkout_session
  end

  def call
    reservation.transaction do
      # this is a little hacky, but it makes sure that ChargeDescription is set correctly
      # otherwise the payment history on the membership looks strange
      charge.state = ::Charge::STATE_SUCCESSFUL
      charge.update!(
        state: ::Charge::STATE_SUCCESSFUL,
        stripe_response: json_to_hash(stripe_checkout_session),
        comment: ChargeDescription.new(charge).for_users,
      )
      if fully_paid?
        reservation.update!(state: Reservation::PAID)
      else
        reservation.update!(state: Reservation::INSTALMENT)
      end
    end

    trigger_payment_mailer

    return charge
  end

  def error_message
    errors.to_sentence
  end

  def errors
    @errors ||= []
  end

  private

  def json_to_hash(obj)
    JSON.parse(obj.to_json)
  rescue
    {}
  end

  def fully_paid?
    reservation.charges.successful.sum(&:amount_cents) >= reservation.membership.price_cents
  end

  def outstanding_amount
    Money.new(reservation.membership.price_cents - reservation.charges.successful.sum(&:amount_cents), ENV.fetch("STRIPE_CURRENCY"))
  end

  def trigger_payment_mailer
    if charge.reservation.instalment?
      PaymentMailer.instalment(
        user: reservation.user,
        charge: charge,
        outstanding_amount: outstanding_amount.format(with_currency: true)
      ).deliver_later
    else
      PaymentMailer.paid(
        user: reservation.user,
        charge: charge,
      ).deliver_later
    end
  end

  def reservation
    charge.reservation
  end
end
