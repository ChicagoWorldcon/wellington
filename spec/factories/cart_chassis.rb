# frozen_string_literal: true

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

FactoryBot.define do
  factory :cart_chassis do

    transient do
      chassis_user { create(:user)}
      now_bin { create(:cart)}
      later_bin { create(:cart, :for_later_bin)}
    end

    after(:build) do |cart_chassis, eval|
      cart_chassis.now_bin = eval.now_bin
      cart_chassis.later_bin = eval.later_bin
      cart_chassis.now_bin.update_attribute(:user, eval.chassis_user)
      cart_chassis.later_bin.update_attribute(:user, eval.chassis_user)
    end

    skip_create

    trait :with_basic_items_cart_for_now do

      transient do
        now_bin { create(:cart, :with_basic_items)}
      end

      # after(:build) do |cart_chassis, eval|
      #   cart_chassis.now_bin.update_attribute(:active_to, 1.day.ago)
      #   cart_chassis.now_bin = eval.trait_now_bin
      #   cart_chassis.now_bin.update_attribute(:user, eval.chassis_user)
      # end
    end

    trait :with_basic_items_cart_for_later do
      transient do
        later_bin { create(:cart, :with_basic_items, :for_later_bin)}
      end

      # after(:build) do |cart_chassis, eval|
      #   cart_chassis.later_bin.update_attribute(:active_to, 1.day.ago)
      #   cart_chassis.later_bin = eval.trait_later_bin
      #   cart_chassis.now_bin.update_attribute(:user, eval.chassis_user)
      # end
    end

    trait :with_unpaid_reservations_cart_for_now do
      transient do
        now_bin { create(:cart, :with_unpaid_reservation_items)}
      end

      # after(:build) do |cart_chassis, eval|
      #   cart_chassis.now_bin.update_attribute(:active_to, 1.day.ago)
      #   cart_chassis.now_bin = eval.trait_now_bin
      #   cart_chassis.now_bin.update_attribute(:user, eval.chassis_user)
      # end
    end

    trait :with_unpaid_reservations_cart_for_later do
      transient do
        later_bin { create(:cart, :with_unpaid_reservation_items, :for_later_bin )}
      end

      # after(:build) do |cart_chassis, eval|
      #   cart_chassis.later_bin.update_attribute(:active_to, 1.day.ago)
      #   cart_chassis.later_bin = eval.trait_later_bin
      #   cart_chassis.later_bin.update_attribute(:user, eval.chassis_user)
      # end
    end
  end
end
