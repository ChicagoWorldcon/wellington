# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2020 Victoria Garcia
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
    can_site_select { false }
    can_nominate { false }
    can_attend { false }
    dob_required { false }
    price_currency { $currency }

    trait :adult do
      name { :adult }
      price_cents { 370_00 }
      can_vote { true }
      can_site_select { true }
      can_nominate { true }
      can_attend { true }
      dob_required { false }
    end

    trait :young_adult do
      name { :young_adult }
      price_cents { 225_00 }
      description { "born in or after 2000" }
      can_vote { true }
      can_site_select { true }
      can_nominate { true }
      can_attend { true }
      dob_required { true }
    end

    trait :unwaged do
      name { :unwaged }
      price_cents { 225_00 }
      description { "NZ residents only" }
      can_vote { true }
      can_site_select { true }
      can_nominate { true }
      can_attend { true }
      dob_required { false }
    end

    trait :child do
      name { :child }
      price_cents { 105_00 }
      description { "born in or after 2005" }
      can_attend { true }
      dob_required { true }
    end

    trait :kid_in_tow do
      name { :kid_in_tow }
      price_cents { 0 }
      description { "born in or after 2015" }
      can_attend { true }
      dob_required { true }
    end

    trait :supporting do
      name { :supporting }
      price_cents { 75_00 }
      can_vote { true }
      can_site_select { true }
      can_nominate { true }
      dob_required { false }
    end

    # Supporting membership with $50 credit
    trait :supporting_plus do
      name { "supporting+" }
      price_cents { 75_00 + 50_00 }
      can_vote { true }
      can_site_select { true }
      can_nominate { true }
      active_to { 1.day.ago }
      dob_required { false }
    end

    trait :press_pass do
      name { :press_pass }
      price_cents { 0 }
      can_attend { true }
      active_to { 1.day.ago }
      dob_required { false }
    end

    trait :sponsor do
      name { :sponsor }
      price_cents { 0 }
      can_attend { true }
      active_to { 1.day.ago }
      dob_required { false }
    end

    trait :dealer do
      name { :dealer }
      price_cents { 0 }
      can_attend { true }
      active_to { 1.day.ago }
      dob_required { false }
    end

    trait :silver_fern do
      name { :silver_fern }
      price_cents { 370_00 - 50_00 }
      active_to { 1.day.ago }
      description { "Presupport membership" }
      dob_required { false }
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
      dob_required { false }
    end

    trait :pre_oppose do
      name { :pre_oppose }
      price_cents { 0 }
      active_to { 1.day.ago }
      description { "Presupport membership" }
      dob_required { false }
    end

    trait :pre_support do
      name { :pre_support }
      price_cents { 0 }
      active_to { 1.day.ago }
      description { "Presupport membership" }
      dob_required { false }
    end

    trait :dublin_2019 do
      name { :dublin_2019 }
      price_cents { 0 }
      active_from { 1.day.ago }
      active_to { 1.day.ago }
      can_vote { false }
      can_site_select { false }
      can_nominate { true }
      description { "Attended Dublin in 2019, can Nominate in 2020" }
      dob_required { false }
    end

    trait :chicago_donor do
      name { :donor }
      price_cents { 20_00 }
      description { "With our thanks!" }
      dob_required { false }
    end

    trait :chicago_friend do
      name { :donor }
      price_cents { 150_00 }
      description {  "Will convert to an attending membership automatically if you vote in tion in 2020" }
      dob_required { false }
    end

    trait :chicago_star do
      name { :donor }
      price_cents { 500_00 }
      description { "Will convert to an attending membership automatically if you vote in Site Selection in 2020, and hing cool for you at the convention! (Shhh…it’s a surprise!)" }
      dob_required { false }
    end

    trait :with_order_for_reservation do
      after(:create) do |new_membership, _evaluator|
        new_membership.orders << create(:order, :with_reservation, membership: new_membership)
      end
    end
  end
end
