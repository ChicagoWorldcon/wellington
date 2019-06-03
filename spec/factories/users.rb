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
  factory :user do
    email { Faker::Internet.unique.email }

    trait :with_reservation do
      after(:create) do |new_user|
        claim = create(:claim, :with_reservation, user: new_user)
        membership_price = claim.reservation.membership.price
        charge = create(:charge, user: new_user, reservation: claim.reservation, amount: membership_price)
        new_user.claims << claim
        new_user.charges << charge
      end
    end
  end
end
