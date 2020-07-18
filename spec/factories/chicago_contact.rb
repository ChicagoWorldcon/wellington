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
  factory :chicago_contact do
    address_line_1 { Faker::Address.street_address }
    country { Faker::Address.city }
    title { Faker::Superhero.prefix }
    first_name { Faker::Superhero.name }
    last_name { Faker::Superhero.suffix }
    publication_format { ConzealandContact::PAPERPUBS_ELECTRONIC }
    date_of_birth { Faker::Date.birthday(min_age: 0, max_age: 25)}

    claim { build(:claim, :with_user, :with_reservation) }

    trait :with_claim do
      after(:build) do |new_contact, _evaluator|
        new_contact.claim = create(:claim, :with_user, :with_reservation)
      end
    end

    trait :paperpubs_mail do
      publication_format { ConzealandContact::PAPERPUBS_MAIL }
    end

    trait :paperpubs_all do
      publication_format { ConzealandContact::PAPERPUBS_BOTH }
    end

    trait :paperpubs_none do
      publication_format { ConzealandContact::PAPERPUBS_NONE }
    end
  end
end
