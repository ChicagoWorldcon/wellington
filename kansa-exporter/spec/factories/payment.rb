# frozen_string_literal: true

# Copyright 2018 Andrew Esler
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
  factory :payment do
    sequence(:id) { |n| n }
    sequence(:stripe_charge_id) { |n| "ch_#{n.to_s.rjust(15, "0")}" }
    sequence(:stripe_token) { |n| "tok_#{n.to_s.rjust(15, "0")}" }
    status { "succeeded" }
    amount { 19500 }
    currency { $currency }
    type { "Adult" }
    category {  "new_member" }
    created { Time.now }
  end
end
