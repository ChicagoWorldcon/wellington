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
  factory :claim do
    active_from { 1.week.ago }
    created_at { 1.week.ago }

    trait :with_reservation do
      after(:build) do |claim, _evaluator|
        claim.reservation = create(:reservation, :with_order_against_membership)
      end
    end

    trait :with_user do
      after(:build) do |claim, _evaluator|
        claim.user = create(:user)
      end
    end

    trait :with_conzealand_contact do
      after(:build) do |new_claim, _evaluator|
        new_claim.conzealand_contact = create(:conzealand_contact, claim: new_claim)
      end
    end

    trait :with_chicago_contact do
      after(:build) do |new_claim, _evaluator|
        new_claim.chicago_contact = create(:chicago_contact, claim: new_claim)
      end
    end
  end
end
