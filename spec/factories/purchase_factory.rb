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

FactoryBot.define do
  factory :purchase do
    level { "adult" }
    worth { 300 }
    state { Purchase::ACTIVE }
    created_at { 1.week.ago }

    trait :pay_as_you_go do
      state { Purchase::INSTALLMENT }
    end

    trait :with_order_against_product do
      after(:create) do |new_purchase, _evaluator|
        new_purchase.orders << create(:order, :with_product, purchase: new_purchase)
      end
    end

    trait :with_claim_from_user do
      after(:create) do |new_purchase, _evaluator|
        new_purchase.claims << create(:claim, :with_user, purchase: new_purchase)
      end
    end
  end
end
