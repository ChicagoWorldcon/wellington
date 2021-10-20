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

class StripeWebhooksController < ActionController::Base
  # stripe webhooks don't have access to the Rails CSRF token, so we
  # instead use Stripe::Webhook.construct_event to verify authenticity
  skip_forgery_protection

  def receive
    event = nil

    # Verify webhook signature and extract the event
    # See https://stripe.com/docs/webhooks/signatures for more information.
    begin
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      payload = request.body.read
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      # Invalid payload
      head :bad_request
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      head :bad_request
    end
  
    case
    when event['type'] == 'checkout.session.completed'
      checkout_session = event['data']['object']
      checkout_session_completed(checkout_session)
    when event['type'] == 'checkout.session.expired'
      checkout_session = event['data']['object']
      checkout_session_expired(checkout_session)
    else
      # silently ignore
      head :ok
    end
  end

  private
  def endpoint_secret
    ENV['STRIPE_WEBHOOK_ENDPOINT_SECRET'] || raise("must have STRIPE_WEBHOOK_ENDPOINT_SECRET configured for payments") 
  end

  def checkout_session_completed(stripe_checkout_session)
    charge = Charge.find_by!(stripe_id: stripe_checkout_session['id'])

    service = Money::StripeCheckoutSucceeded.new(
      charge: charge,
      stripe_checkout_session: stripe_checkout_session,
    )

    after_success_actions_completed = service.call
    if after_success_actions_completed
      head :ok
    else 
      head :unprocessable_entity
    end
  end

  def checkout_session_expired(stripe_checkout_session)
    charge = Charge.find_by!(stripe_id: stripe_checkout_session['id'])

    service = Money::StripeCheckoutFailed.new(
      charge: charge,
      stripe_checkout_session: stripe_checkout_session,
    )

    after_expire_actions_completed = service.call
    if after_expire_actions_completed
      head :ok
    else 
      head :unprocessable_entity
    end
  end
end
