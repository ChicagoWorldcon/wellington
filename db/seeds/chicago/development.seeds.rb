# frozen_string_literal: true
#
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


users_to_create = (ENV["SEED_USER_COUNT"] || "50").to_i

all_memberships = Membership.all.to_a

users_to_create.times do |count|
  puts "Seeding #{count} of 50 users" if count % 5 == 0
  new_user = FactoryBot.create(:user)
  memberships_held = membership_distribution_averages.sample # <-- biased random number

  all_memberships.sample(memberships_held).each do |rando_membership|
    if rando_membership.price == 0
      state = Reservation::PAID
    else
      state = [Reservation::PAID, Reservation::INSTALMENT].sample
    end

    FactoryBot.create(:reservation, user: new_user, membership: rando_membership, state: state)
  end

  new_user.active_claims.each do |claim|
    claim.update!(contact: FactoryBot.create(:chicago_contact, claim: claim))
  end
end

if users_to_create > 0
  puts "\nFinished creating users, try sign in with"
  puts "#{User.last.email}"
end

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
puts

# Avoid sending system emails for generated nominations
Reservation.update_all(ballot_last_mailed_at: Time.now)

# FIXME:  The rest of tihs process is commented out pending figuring out why
# ./development_finalist.seeds.rb is causing failures.
#
# puts "Creating finalists..."
# require_relative "./development_finalist.seeds.rb"
# require_relative "./development_rename_hugo.seeds.rb"
#
# puts "Ranking finalists..."
# finalists_by_category = Finalist.all.to_a.group_by(&:category_id)
# reservations_with_voting = Reservation.joins(:membership).merge(Membership.with_voting_rights)
# total = reservations_with_voting.count
# reservations_with_voting.find_each.with_index do |reservation, n|
#   puts "#{n}/#{total} reservations ranked" if n % 10 == 0
#
#   finalists_by_category.each do |(category_id, finalists)|
#     count = rand(0..7)
#     finalists.sample(count).each.with_index(1) do |finalist, position|
#       Rank.create!(
#         finalist: finalist,
#         reservation: reservation,
#         position: position,
#       )
#     end
#   end
# end

users_with_active_carts = User.first(users_to_create / 4)

now_bin_types = [:with_empty_now_bin, :with_basic_items_cart_for_now, :with_unpaid_reservations_cart_for_now, :with_partially_paid_reservations_cart_for_now, :with_paid_reservations_cart_for_now]

later_bin_types = [:with_empty_later_bin, :with_basic_items_cart_for_later, :with_unpaid_reservations_cart_for_later, :with_partially_paid_reservations_cart_for_later,  :with_paid_reservations_cart_for_later]

users_with_active_carts.each.with_index(1) do |u, i|
  puts "Generated active carts for for #{i}/#{users_with_active_carts.count} users" if i % 4 == 0

  now_type = now_bin_types[rand(0...now_bin_types.length)]
  later_type = later_bin_types[rand(0...later_bin_types.length)]

  FactoryBot.build(:cart_chassis, now_type, later_type, chassis_user: u)
end
puts
puts

users_with_paid_carts = User.last(users_to_create /5)
paid_cart_types = [:fully_paid_through_single_direct_charge, :fully_paid_through_direct_charge_and_paid_item_combo]

users_with_paid_carts.each.with_index(1) do |u, i|
  puts "Generated paid carts for for #{i}/#{users_with_paid_carts.count} users" if i % 3 == 0

  type = paid_cart_types[rand(0.0..1.0).round()]
  FactoryBot.create(:cart, type, :paid, user: u)
end

puts "finished seeding"
