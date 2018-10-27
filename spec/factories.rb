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

# Factories to simplify testing
# see https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md
FactoryBot.define do
  sequence :email do |n|
    "fan-#{n}@convention.net"
  end

  factory :user do
    email { generate(:email) }
  end

  factory :purchase do
    level { "adult" }
    worth { 300 }
    state { Purchase::ACTIVE }
    created_at { 1.week.ago }

    trait :pay_as_you_go do
      state { Purchase::INSTALLMENT }
    end
  end

  factory :product do
    category { :membership }
    level { "adult" }
    price { 300 }
    active_from { 1.week.ago }
    created_at { 1.week.ago }
  end

  factory :order do
    active_from { 1.week.ago }
    created_at { 1.week.ago }

    before(:create) do |order, _evaluator|
      order.purchase = create(:purchase)
      order.product = create(:product)
    end
  end
end
