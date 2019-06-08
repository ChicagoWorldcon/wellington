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
  sequence(:next_membership_number)

  factory :reservation do
    state { Reservation::PAID }
    created_at { 1.week.ago }
    membership_number { generate(:next_membership_number) }

    trait :pay_as_you_go do
      state { Reservation::INSTALLMENT }
    end

    trait :with_order_against_membership do
      after(:create) do |new_reservation, _evaluator|
        new_reservation.orders << create(:order, :with_membership, reservation: new_reservation)
      end
    end

    trait :with_claim_from_user do
      after(:build) do |new_reservation, _evaluator|
        new_claim = build(:claim, :with_user, reservation: new_reservation)
        new_claim.detail = build(:detail, claim: new_claim)
        new_reservation.claims << new_claim
      end
    end
  end
end
