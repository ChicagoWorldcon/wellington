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
      acquirable { create(:membership, :adult)}
      benefitable { create(:chicago_contact)}
    end

    after(:build) do |cart_item, evaluator|
      cart_item.acquirable = evaluator.acquirable
      cart_item.benefitable = evaluator.benefitable
    end

    trait :with_kidit do
      transient do
        acquirable { create(:membership, :kidit)}
      end
      after(:build) do |cart_item, evaluator|
        cart_item.acquirable = evaluator.acquirable
      end
    end

    trait :with_ya do
      transient do
        acquirable { create(:membership, :ya)}
      end
      after(:build) do |cart_item, evaluator|
        cart_item.acquirable = evaluator.acquirable
      end
    end

    trait :with_supporting do
      transient do
        acquirable { create(:membership, :supporting)}
      end
      after(:build) do |cart_item, evaluator|
        cart_item.acquirable = evaluator.acquirable
      end
    end

    trait :with_expired_membership_tuatara do
      transient do
        acquirable { create(:membership, :tuatara)}
      end
      after(:build) do |cart_item, evaluator|
        cart_item.acquirable = evaluator.acquirable
      end
    end

    trait :with_expired_membership_silver_f do
      transient do
        acquirable { create(:membership, :silver_fern)}
      end
      after(:build) do |cart_item, evaluator|
        cart_item.acquirable = evaluator.acquirable
      end
    end

    trait :saved_for_later do
      later {true}
    end

    trait :unavailable do
      before(:create) do |cart_item, evaluator|
        cart_item.available = false;
      end
    end

    trait :price_altered do
      before(:create) do |cart_item, evaluator|
        cart_item.item_price_memo += 100
      end
    end

    trait :name_altered do
      before(:create) do |cart_item, evaluator|
        cart_item.item_name_memo = "altered"
      end
    end

    trait :uknown_kind do
      after(:create) do |cart_item, evaluator|
        cart_item.kind = "unknown"
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
