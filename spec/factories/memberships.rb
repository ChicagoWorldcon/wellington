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
    can_vote { false }
    can_attend { false }
    price_currency { $currency }

    trait :adult do
      name { :adult }
      price_cents { 370_00 }
      can_vote { true }
      can_attend { true }
    end

    trait :young_adult do
      name { :young_adult }
      price_cents { 225_00 }
      description { "born in or after 2000" }
      can_vote { true }
      can_attend { true }
    end

    trait :unwaged do
      name { :unwaged }
      price_cents { 225_00 }
      description { "NZ residents only" }
      can_vote { true }
      can_attend { true }
    end

    trait :child do
      name { :child }
      price_cents { 105_00 }
      description { "born in or after 2005" }
      can_attend { true }
    end

    trait :kid_in_tow do
      name { :kid_in_tow }
      price_cents { 0 }
      description { "born in or after 2015" }
      can_attend { true }
    end

    trait :supporting do
      name { :supporting }
      price_cents { 75_00 }
      can_vote { true }
    end

    # Supporting membership with $50 credit
    trait :supporting_plus do
      name { "supporting+" }
      price_cents { 75_00 + 50_00 }
      can_vote { true }
      active_to { 1.day.ago }
    end

    trait :press_pass do
      name { :press_pass }
      price_cents { 0 }
      can_attend { true }
      active_to { 1.day.ago }
    end

    trait :sponsor do
      name { :sponsor }
      price_cents { 0 }
      can_attend { true }
      active_to { 1.day.ago }
    end

    trait :dealer do
      name { :dealer }
      price_cents { 0 }
      can_attend { true }
      active_to { 1.day.ago }
    end

    trait :silver_fern do
      name { :silver_fern }
      price_cents { 370_00 - 50_00 }
      active_to { 1.day.ago }
      description { "Presupport membership" }
    end

    trait :kiwi do
      name { :kiwi }
      price_cents { 50_00 }
      description { "Presupport membership" }
    end

    trait :tuatara do
      name { :tuatara }
      price_cents { 0 }
      active_to { 1.day.ago }
      description { "Presupport membership" }
    end

    trait :pre_oppose do
      name { :pre_oppose }
      price_cents { 0 }
      active_to { 1.day.ago }
      description { "Presupport membership" }
    end

    trait :pre_support do
      name { :pre_support }
      price_cents { 0 }
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
