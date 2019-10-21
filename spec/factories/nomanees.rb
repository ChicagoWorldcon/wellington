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
  factory :nomanee do
    field_1 { Faker::Book.title }
    field_2 { Faker::Book.author }
    field_3 { Faker::Book.publisher }

    trait :with_nominations do
      after :create do |new_nomanee, _evaluator|
        3.times do
          new_nomanee.nominations << create(:nomination)
        end
      end
    end
  end
end
