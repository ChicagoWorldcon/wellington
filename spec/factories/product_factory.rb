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
  factory :product do
    category { :membership }
    active_from { 1.week.ago }
    created_at { 1.week.ago }

    trait :adult do
      level { :adult }
      price { 340_00 }
    end

    trait :young_adult do
      level { :young_adult }
      price { 225_00 }
    end

    trait :unwaged do
      level { :unwaged }
      price { 225_00 }
    end

    trait :child do
      level { :child }
      price { 105_00 }
    end

    trait :kid_in_tow do
      level { :kid_in_tow }
      price { 0 }
    end

    trait :supporting do
      level { :supporting }
      price { 75_00 }
    end

    trait :with_order_for_purchase do
      after(:create) do |new_product, _evaluator|
        new_product.orders << create(:order, :with_purchase, product: new_product)
      end
    end
  end
end
