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
  factory :dc_contact do
    first_name { Faker::Superhero.name }
    middle_name { Faker::Superhero.descriptor }
    last_name { Faker::Superhero.power }
    suffix { Faker::Superhero.suffix }

    preferred_pronoun { Faker::Superhero.prefix }
    phone_number { Faker::PhoneNumber.phone_number_with_country_code }

    address { Faker::Address.street_address }
    city_or_town { Faker::Address.city }
    state_province_or_region { Faker::Address.state }
    postal_code { Faker::Address.zip_code }
    country { Faker::Address.country }

    after(:build) do |new_contact, _evaluator|
      if new_contact.claim.nil?
        new_contact.claim = build(:claim, :with_reservation, :with_user)
      end
    end
  end
end
