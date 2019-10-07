# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 Chris Rose
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

announcement = Date.parse("2018-08-25").midday
presupport_start = announcement - 2.years

FactoryBot.create(:membership, :silver_fern , active_from: presupport_start, active_to: announcement)
FactoryBot.create(:membership, :kiwi        , active_from: presupport_start, active_to: announcement)
FactoryBot.create(:membership, :tuatara     , active_from: presupport_start, active_to: announcement)
FactoryBot.create(:membership, :pre_oppose  , active_from: presupport_start, active_to: announcement)
FactoryBot.create(:membership, :pre_support , active_from: presupport_start, active_to: announcement)

FactoryBot.create(:membership, :adult       , active_from: announcement)
FactoryBot.create(:membership, :young_adult , active_from: announcement)
FactoryBot.create(:membership, :unwaged     , active_from: announcement)
FactoryBot.create(:membership, :child       , active_from: announcement)
FactoryBot.create(:membership, :kid_in_tow  , active_from: announcement)
FactoryBot.create(:membership, :supporting  , active_from: announcement)

all_memberships = Membership.all.to_a

50.times do |count|
  puts "Seeding #{count} of 50 users" if count % 5 == 0
  new_user = FactoryBot.create(:user)
  memberships_held = rand(2..10)
  all_memberships.sample(memberships_held).each do |rando_membership|
    if rando_membership.price == 0
      state = Reservation::PAID
    else
      state = [Reservation::PAID, Reservation::INSTALMENT].sample
    end

    reservation = FactoryBot.create(:reservation, user: new_user, membership: rando_membership, state: state)
  end
  new_user.active_claims.each do |claim|
    claim.update!(detail: FactoryBot.create(:detail, claim: claim))
  end
end

# Create a default support user
# http://localhost:3000/supports/sign_in
Support.create(
  email: "support@worldcon.org",
  password: 111111,
  confirmed_at: Time.now,
)
