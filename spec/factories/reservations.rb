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
      number_of_charges {1}
      charge_state { Charge::STATE_SUCCESSFUL }
      charge_transfer { Charge::TRANSFER_STRIPE }
    end

    trait :instalment do
      state { Reservation::INSTALMENT }
    end

    trait :disabled do
      state { Reservation::DISABLED }
    end

    trait :with_failed_charge do
      transient do
        charge_state { Charge::STATE_FAILED }
      end
      with_order_against_membership
      with_claim_from_user
    end

    trait :with_pending_charge do
      after(:build) do |new_res, evaluator|
        evaluator.charge_state = Charge::STATE_PENDING
      end
    end

    trait :with_cash_charge do
      after(:build) do |new_res, evaluator|
        evaluator.charge_transfer = Charge::TRANSFER_CASH
      end
    end

    trait :with_several_charges do
      after(:build) do |new_res, evaluator|
        evaluator.number_of_charges = 3
      end
    end

    after(:create) do |new_reservation, evaluator|
      next unless new_reservation.membership.present?
      next unless new_reservation.user.present?

      binding.pry

      if new_reservation.paid? || ( new_reservation.instalment? && evaluator.instalment_paid > 0 )
        cents_to_charge = new_reservation.instalment? ? evaluator.instalment_paid : new_reservation.membership.price_cents
        charges_remaining = evaluator.number_of_charges

        create_list(:charge, evaluator.number_of_charges, :generate_description,
          state: evaluator.charge_state,
          transfer: evaluator.charge_transfer,
          user: new_reservation.user,
          buyable: new_reservation,
          # amount: new_reservation.membership.price
        ) do |charge, i|
          unless charges_remaining <= 0
            binding.pry
            charge.amount_cents = (cents_to_charge / charges_remaining ) + (cents_to_charge % charges_remaining)
            charges_remaining -= 1
            cents_to_charge -= charge.amount_cents
          end
        end
      #
      # elsif new_reservation.instalment? && evaluator.instalment_paid > 0
      #   create(:charge, :generate_description,
      #     user: new_reservation.user,
      #     buyable: new_reservation,
      #     # reservation: new_reservation,
      #     amount: evaluator.instalment_paid,
      #   )
      end
    end

    trait :with_order_against_membership do
      after(:build) do |new_reservation, _evaluator|
        create(:order, :with_membership,
        reservation: new_reservation
      )
        new_reservation.reload
      end
    end

    trait :with_claim_from_user do
      after(:build) do |new_reservation, _evaluator|
        new_claim = build(:claim, :with_user, :with_contact,
        reservation: new_reservation
        )
        new_reservation.claims << new_claim
      end
    end
  end
end
