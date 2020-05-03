# frozen_string_literal: true

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

# Checkout controller creates
class CheckoutController < ApplicationController
  def index
    # @stripe_checkout_session = Stripe::Checkout::Session.create(
    #   payment_method_types: ['card'],
    #   # This looks exactly like what they want for Chicago
    #   line_items: [{
    #     name: 'Custom t-shirt',
    #     description: 'Your custom designed t-shirt',
    #     amount: 1_00, # Gold coin donation <3
    #     currency: 'nzd',
    #     quantity: 1,
    #   }],
    #   success_url: finalise_checkout_url,
    #   cancel_url: cancel_checkout_url,
    # )
  end

  def finalise
    binding.pry # FIXME commit = death
  end

  def cancel
    binding.pry # FIXME commit = death
  end
end
