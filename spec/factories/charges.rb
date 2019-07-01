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

FactoryBot.define do
  factory :charge do
    association :user
    association :reservation
    amount_currency { $currency }

    comment { "Factory Generated Charge" }
    amount_cents { 3_00 } # cents
    sequence(:stripe_id) { |n| "ch_faked9EaQ9ZgIF2tWC8ffake#{n}" }
    state { Charge::STATE_SUCCESSFUL }
    transfer { Charge::TRANSFER_STRIPE }

    trait(:failed) do
      state { Charge::STATE_FAILED }
    end
  end
end
