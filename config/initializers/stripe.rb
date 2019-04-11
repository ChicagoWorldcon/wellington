# frozen_string_literal: true

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

# See https://stripe.com/docs/checkout/rails
Rails.configuration.stripe = {
  publishable_key: ENV["STRIPE_PUBLIC_KEY"],
  secret_key: ENV["STRIPE_PRIVATE_KEY"],
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]

$stripe_test_keys = ENV["STRIPE_PRIVATE_KEY"].present? && !!ENV["STRIPE_PRIVATE_KEY"].match(/^sk_test/)
