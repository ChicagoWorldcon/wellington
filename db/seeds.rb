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

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#

announcement = Date.parse("2018-08-25").midday
presupport_start = announcement - 2.years
adult_membership = Membership.create!(name: :adult, active_from: announcement, price: 370_00)

Membership.create!(name: :silver_fern , active_from: presupport_start, active_to: announcement , price: adult_membership.price - 50_00)
Membership.create!(name: :kiwi        , active_from: presupport_start, active_to: announcement , price: adult_membership.price - 150_00)
Membership.create!(name: :tuatara     , active_from: presupport_start, active_to: announcement , price: 0)
Membership.create!(name: :pre_oppose  , active_from: presupport_start, active_to: announcement , price: 0)
Membership.create!(name: :pre_support , active_from: presupport_start, active_to: announcement , price: 0)

Membership.create!(name: :young_adult , active_from: announcement , price: 225_00)
Membership.create!(name: :unwaged     , active_from: announcement , price: 225_00)
Membership.create!(name: :child       , active_from: announcement , price: 105_00)
Membership.create!(name: :kid_in_tow  , active_from: announcement , price: 0)
Membership.create!(name: :supporting  , active_from: announcement , price: 75_00)

# Sample users and details
100.times do |count|
  puts "Seeding #{count} of 100 users" if count % 10 == 0
  user = FactoryBot.create(:user, :with_purchase)
  user.active_claims.each do |claim|
    claim.update!(detail: FactoryBot.create(:detail, claim: claim))
  end
end
