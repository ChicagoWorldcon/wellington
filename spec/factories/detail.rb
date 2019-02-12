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
  factory :detail do
    address_line_1 { Faker::Address.street_address }
    country { Faker::Address.city }
    first_name { Faker::VentureBros.character }
    publication_format { Detail::PAPERPUBS_ELECTRONIC }

    trait :with_claim do
      after(:build) do |new_detail, _evaluator|
        new_detail.claim = create(:claim, :with_user, :with_purchase)
      end
    end

    trait :paperpubs_mail do
      publication_format { Detail::PAPERPUBS_MAIL }
    end

    trait :paperpubs_all do
      publication_format { Detail::PAPERPUBS_BOTH }
    end

    trait :paperpubs_none do
      publication_format { Detail::PAPERPUBS_NONE }
    end
  end
end
