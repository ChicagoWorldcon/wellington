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
    membership_number { generate(:next_membership_number) }

    trait :pay_as_you_go do
      state { Reservation::INSTALLMENT }
    end

    trait :with_charges do
      after(:create) do |new_reservation, _evaluator|
        raise "membership required" unless new_reservation.membership.present?
        raise "user required" unless new_reservation.user.present?

        if new_reservation.paid?
          create(:charge, :generate_description, user: new_reservation.user, reservation: new_reservation, amount: new_reservation.membership.price)
        elsif new_reservation.installment?
          number_of_installments = rand(1..3)
          fraction_paid = rand(10..90).to_d / 100
          amount = (fraction_paid * new_reservation.membership.price) / number_of_installments

          number_of_installments.times do
            create(:charge, :generate_description, user: new_reservation.user, reservation: new_reservation, amount: amount)
          end
        end
      end
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
