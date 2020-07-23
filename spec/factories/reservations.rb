# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 AJ Esler
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

    membership_number do
      if last_number = Reservation.maximum(:membership_number)
        last_number + 1
      else
        1
      end
    end

    transient do
      instalment_paid { Money.new(75_00) }
    end

    trait :instalment do
      state { Reservation::INSTALMENT }
    end

    trait :disabled do
      state { Reservation::DISABLED }
    end

    after(:create) do |new_reservation, evaluator|
      next unless new_reservation.membership.present?
      next unless new_reservation.user.present?

      if new_reservation.paid?
        new_charge = create(:charge, :generate_description,
          user: new_reservation.user,
          amount: new_reservation.membership.price
        )
        create(:reservation_charge, reservation: new_reservation, charge: new_charge)
      elsif new_reservation.instalment? && evaluator.instalment_paid > 0
        new_charge = create(:charge, :generate_description,
          user: new_reservation.user,
          amount: evaluator.instalment_paid,
        )
        create(:reservation_charge, reservation: new_reservation, charge: new_charge)
      end
    end

    trait :with_order_against_membership do
      after(:build) do |new_reservation, _evaluator|
        create(:order, :with_membership, reservation: new_reservation)
        new_reservation.reload
      end
    end

    trait :with_claim_for_user do
      transient do
        user { create(:user) }
      end

      after(:build) do |new_reservation, evaluator|
        new_claim = build(:claim, :with_contact, reservation: new_reservation, user: evaluator.user)
        new_reservation.claims << new_claim
      end
    end

    trait :with_claim_from_user do
      after(:build) do |new_reservation, _evaluator|
        new_claim = build(:claim, :with_user, :with_contact, reservation: new_reservation)
        new_reservation.claims << new_claim
      end
    end
  end
end
