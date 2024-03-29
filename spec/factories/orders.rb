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
  factory :order do
    active_from { 1.week.ago }
    created_at { 1.week.ago }

    trait :with_reservation do
      before(:create) do |order, _evaluator|
        order.reservation = create(:reservation)
      end
    end

    trait :with_membership do
      before(:create) do |order, _evaluator|
        order.membership = Membership.find_by(name: :adult) || create(:membership, :adult)
      end
    end

    trait :with_supporting_membership do
      before(:create) do |order, _evaluator|
        order.membership = Membership.find_by(name: :supporting ) || create(:membership, :supporting)
      end
    end
  end
end
