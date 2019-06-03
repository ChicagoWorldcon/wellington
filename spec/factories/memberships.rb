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
  factory :membership do
    active_from { 1.week.ago }
    created_at { 1.week.ago }

    trait :adult do
      name { :adult }
      price { 370_00 }
    end

    trait :young_adult do
      name { :young_adult }
      price { 225_00 }
      description { "born in or after 2000" }
    end

    trait :unwaged do
      name { :unwaged }
      price { 225_00 }
      description { "NZ residents only" }
    end

    trait :child do
      name { :child }
      price { 105_00 }
      description { "born in or after 2005" }
    end

    trait :kid_in_tow do
      name { :kid_in_tow }
      price { 0 }
      description { "born in or after 2015" }
    end

    trait :supporting do
      name { :supporting }
      price { 75_00 }
    end

    trait :silver_fern do
      name { :silver_fern }
      price { 370_00 - 50_00 }
      active_to { 1.day.ago }
      description { "Presupport membership" }
    end

    trait :kiwi do
      name { :kiwi }
      price { 50_00 }
      active_to { 1.day.ago }
      description { "Presupport membership" }
    end

    trait :tuatara do
      name { :tuatara }
      price { 0 }
      active_to { 1.day.ago }
      description { "Presupport membership" }
    end

    trait :pre_oppose do
      name { :pre_oppose }
      price { 0 }
      active_to { 1.day.ago }
      description { "Presupport membership" }
    end

    trait :pre_support do
      name { :pre_support }
      price { 0 }
      active_to { 1.day.ago }
      description { "Presupport membership" }
    end

    trait :with_order_for_reservation do
      after(:create) do |new_membership, _evaluator|
        new_membership.orders << create(:order, :with_reservation, membership: new_membership)
      end
    end
  end
end
