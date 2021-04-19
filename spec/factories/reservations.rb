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
      instalment_paid { Money.new(15_00) }
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

    trait :with_any_charges_failing do
      transient do
        charge_state { Charge::STATE_FAILED }
      end
    end

    trait :with_any_charges_pending do
      transient do
        charge_state { Charge::STATE_PENDING }
      end
    end

    trait :with_any_charges_in_cash do
      transient do
        charge_state { Charge::STATE_PENDING }
      end
    end

    trait :with_two_charges_if_any do
      transient do
        number_of_charges { 2 }
      end
    end

    trait :with_seven_charges_if_any do
      transient do
        number_of_charges { 7 }
      end
    end

    trait :with_charge_creation do
      with_order_against_membership
      with_claim_from_user
    end

    after(:create) do |new_reservation, evaluator|
      next unless new_reservation.membership.present?
      next unless new_reservation.user.present?

      binding.pry

      if new_reservation.paid? || ( new_reservation.instalment? && evaluator.instalment_paid > 0 )
        cents_to_charge = new_reservation.instalment? ? evaluator.instalment_paid.cents : new_reservation.membership.price_cents
        create_list(:charge, evaluator.number_of_charges, :generate_description,
          state: evaluator.charge_state,
          transfer: evaluator.charge_transfer,
          user: new_reservation.user,
          buyable: new_reservation,
          # amount: new_reservation.membership.price
        ) do |charge, i|
          charges_left_to_make = evaluator.number_of_charges - i
          binding.pry
          unless charges_left_to_make == 0
            current_charge = (cents_to_charge / charges_left_to_make ) + (cents_to_charge % charges_left_to_make)
            binding.pry
            cents_to_charge = cents_to_charge - current_charge
            charge.amount_cents = current_charge
            charge.save
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
