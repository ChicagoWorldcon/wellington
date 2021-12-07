# frozen_string_literal: true
#
# Copyright 2021 Victoria Garcia
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

# NOTE: :benefitable and :acquirable are polymorphic
# associations.  This strategy is being employed for the
# cart to: (a) Make the cart as Con-agnostic as possible,
# and (b) Pave the way for items other than prospective
# reservations to be put in the cart.

#     At present, we are only making objects for the forms of the
# polymorphisms that are currently in play.  However in the future, when more
# forms of the polymorphisms come into being, we will need to expand on what
# we're doing here.
#     A few different options for accomplishing that are discussed below:
#     1.   Multiple factory approach:
#          http://markcharlesdesign.blogspot.com/2013/06/factorygirl-with-polymorphic.html
#     2.   Trait-based approach:
#          https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#polymorphic-associations
#     3.   Inheritence-based approach:
#          https://stackoverflow.com/questions/59730495/how-to-test-a-polymorphic-association-with-factorybot-on-rails-5-2

FactoryBot.define do
  factory :cart_item do
    association :cart
    kind {"membership"}

    transient do
      #acquirable { create(:membership, :adult)}
      acquirable { Membership.find_by(name: :adult) || create(:membership, :adult) }
      benefitable { create(:chicago_contact)}
    end

    after(:build) do |cart_item, evaluator|
      cart_item.acquirable = evaluator.acquirable
      cart_item.benefitable = evaluator.benefitable
    end

    trait :with_free_membership do
      transient do
        #acquirable { create(:membership, :kidit)}
        acquirable { Membership.find_by(name: :kidit) || create(:membership, :kidit) }
      end

      after(:build) do |cart_item, evaluator|
        cart_item.acquirable = evaluator.acquirable
      end
    end

    trait :with_expired_membership do
      transient do
        #acquirable { create(:membership, :silver_fern)}
        acquirable { Membership.find_by(name: :silver_fern) || create(:membership, :silver_fern) }
      end

      after(:build) do |cart_item, evaluator|
        cart_item.acquirable = evaluator.acquirable
      end
    end

    trait :with_partially_paid_reservation do
      transient do
        holdable { create(:reservation, :with_order_against_membership, :with_claim_from_user, state: Reservation::INSTALMENT)}
      end

      after(:build) do |cart_item, evaluator|
        cart_item.acquirable = evaluator.holdable.membership
        cart_item.benefitable = evaluator.holdable.active_claim.contact
        cart_item.holdable = evaluator.holdable
      end
    end

    trait :with_unpaid_reservation do
      transient do
        holdable { create(:reservation, :with_order_against_membership, :with_claim_from_user, state: Reservation::DISABLED)}
      end

      after(:build) do |cart_item, evaluator|
        cart_item.acquirable = evaluator.holdable.membership
        cart_item.benefitable = evaluator.holdable.active_claim.contact
        cart_item.holdable = evaluator.holdable
        cart_item.holdable.update_attribute(:state, Reservation::INSTALMENT)
      end
    end

    trait :with_paid_reservation do
      transient do
        holdable { create(:reservation, :with_order_against_membership, :with_claim_from_user)}
      end

      after(:build) do |cart_item, evaluator|
        cart_item.acquirable = evaluator.holdable.membership
        cart_item.benefitable = evaluator.holdable.active_claim.contact
        cart_item.holdable = evaluator.holdable
      end
    end

    trait :unavailable do
      after(:build) do |cart_item, evaluator|
        cart_item.available = false;
      end
    end

    trait :price_altered do
      after(:create) do |cart_item, evaluator|
        altered_price = cart_item.item_price_memo + 100
        cart_item.update_attribute(:item_price_memo, altered_price)
      end
    end

    trait :name_altered do
      after(:create) do |cart_item, evaluator|
        cart_item.update_attribute(:item_name_memo, "altered")
      end
    end

    trait :unknown_kind do
      after(:create) do |cart_item, evaluator|
        cart_item.update_attribute(:kind, "unknown")
      end
    end

    trait :nonmembership_without_benefitable do
      after(:create) do |cart_item, evaluator|
        cart_item.update_attribute(:kind, "unknown")
        cart_item.update_attribute(:benefitable, nil)
      end
    end
  end
end
