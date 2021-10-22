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

# Money::StripeCheckoutFailed updates the Charge record associated with that checkout session to indicate that the payment failed.
# Truthy returns mean that everything updated correctly, otherwise check #errors for failure details.
class Money::StripeCheckoutFailed
  attr_reader :charge, :stripe_checkout_session

  def initialize(charge:, stripe_checkout_session:)
    @charge = charge
    @stripe_checkout_session = stripe_checkout_session
  end

  def call
    reservation = charge.reservation
    reservation.transaction do
      charge.state = ::Charge::STATE_FAILED
      charge.stripe_response = json_to_hash(stripe_checkout_session)
      charge.comment = "Stripe checkout failed."
      charge.save!
    end

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
end
