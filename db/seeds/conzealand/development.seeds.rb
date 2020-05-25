# frozen_string_literal: true

# Copyright 2019 Chris Rose
# Copyright 2020 Matthew B. Gray
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

# Setup memberships

if User.count > 0
  puts "Cowardly refusing to seed a database when we have existing users"
  exit 1
end

puts "Running production seeds"
require_relative "production.seeds.rb"

membership_distribution_averages = [
  1,1,1,1,1,1,1,1,1,1, # 10/20 will be Individuals,
  2,2,2,2,2,           # 5/20 will be Couples,
  3,3,3,               # 3/20 will be Small families,
  5,5,                 # 2/20 will be Families
]


all_memberships = Membership.all.to_a
50.times do |count|
  puts "Seeding #{count} of 50 users" if count % 5 == 0
  new_user = FactoryBot.create(:user)
  memberships_held = membership_distribution_averages.sample # <-- biased random number

  all_memberships.sample(memberships_held).each do |random_purchase|
    if random_purchase.price == 0
      state = Reservation::PAID
    else
      state = [Reservation::PAID, Reservation::INSTALMENT].sample
    end

    new_claim = FactoryBot.create(:claim, :with_contact, user: new_user)
    FactoryBot.create(:reservation, claim: new_claim, membership: random_purchase, state: state)
  end

  new_user.active_claims.each do |claim|
    claim.update!(contact: FactoryBot.create(:conzealand_contact, claim: claim))
  end
end

puts "\nFinished creating users, try sign in with"
puts "#{User.last.email}"

support = Support.create(
  email: "support@worldcon.org",
  password: 111111,
  confirmed_at: Time.now,
)
puts
puts "Support user created"
puts "http://localhost:3000/supports/sign_in"
puts "user: #{support.email}"
puts "pass: 111111"
puts

hugo_admin = Support.create(
  email: "hugoadmin@worldcon.org",
  password: 111111,
  confirmed_at: Time.now,
  hugo_admin: true,
)
puts "Hugo admin created"
puts "http://localhost:3000/supports/sign_in"
puts "user: #{hugo_admin.email}"
puts "pass: 111111"
puts

all_categories = Category.all.to_a
nominators = Reservation.paid.joins(:membership).merge(Membership.with_nomination_rights).to_a

nominators.each.with_index(1) do |reservation, count|
  puts "Generated nominations for #{count}/#{nominators.count} members" if count % 5 == 0
  sampled_categories = all_categories.sample(rand(0..all_categories.count))
  sampled_categories.each do |sample_category|
    rand(1..5).times do
      FactoryBot.create(:nomination, reservation: reservation, category: sample_category)
    end
  end
end

# Avoid sending system emails for generated nominations
Reservation.update_all(ballot_last_mailed_at: Time.now)
