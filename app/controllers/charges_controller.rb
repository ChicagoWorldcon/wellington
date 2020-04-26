# frozen_string_literal: true

# Copyright 2019 AJ Esler
# Copyright 2020 Matthew B. Gray
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

# The ChargesController presents a way for customers to pay money through stripe. On successful or fialed payment,
# we create Charge objects to track what happened and list them against the Reservation.
#
# Note, even if a Reservation is transferred to antoher user, a Charge will always be against the original user that
# it was made out to.
#
# Find test cards are here: https://stripe.com/docs/testing
class ChargesController < ApplicationController
  before_action :lookup_reservation!

  def new
    # You may have used the legacy version of Checkout to

    # 1. create a token or source on the client
    # 2. then passed it to your server to create a charge.

    # The new version of Checkout’s server integration, however, reverses this flow.

    # 1. create a Session on your server, pass its ID to your client
    # 2. redirect your customer to Checkout
    # 3. they then gets redirected back to your application upon success.
    @charge = Charge.create!(
      state: Charge::STATE_PENDING,
      transfer: Charge::TRANSFER_STRIPE,
      user: @reservation.user,
      reservation: @reservation,
      comment: "Pending transaction",
    )

    @session = Stripe::Checkout::Session.create(
      payment_method_types: ['card'],
      # This looks exactly like what they want for Chicago
      line_items: [{
        name: 'Custom t-shirt',
        description: 'Your custom designed t-shirt',
        amount: 1_00, # Gold coin donation <3
        currency: 'nzd',
        quantity: 1,
      }],
      success_url: reservation_charge_url(@reservation, @charge, state: :success),
      cancel_url: reservation_charge_url(@reservation, @charge, state: :cancel),
    )

    @charge.update!(stripe_id: @session.id)
  end

  # TODO also poll for events to know if a user did this
  # https://stripe.com/docs/payments/checkout/one-time
  def show
    @charge = @reservation.charges.find_by!(id: params[:id])
    # @session = Stripe::Charge.retrieve(@charge.stripe_id)

    in_the_last_week = Time.now.utc.to_i - 1.week.to_i
    recent_events = Stripe::Event.list({
      type: 'checkout.session.completed',
      created: { gte: in_the_last_week },
    })

    # TODO expand: %w(balance_transaction)
    found = nil
    recent_events.auto_paging_each.with_index do |event, i|
      checkout_id = event["data"]["object"]["id"]
      if checkout_id == @charge.stripe_id
        found = event
        break
      end
    end

		stripe_charge_id = Stripe::Event.list.first.data.object["charges"].data.first["id"]
    binding.pry # FIXME commit = death
		stripe_charge = Stripe::Charge.retrieve(stripe_charge_id)
		if stripe_charge.status == "failed"
			Stripe::Charge.retrieve(stripe_charge_id).outcome.seller_message
		end
  end

  def create
    # TODO feels like this is where we should be creating the session
  end

  private

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
