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

# Setup memberships

puts "Running production seeds"
require_relative "production.seeds.rb"

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

    FactoryBot.create(:reservation, user: new_user, membership: rando_membership, state: state)
  end

  new_user.active_claims.each do |claim|
    claim.update!(detail: FactoryBot.create(:detail, claim: claim))
  end
end

puts "\nFinished creating users, try sign in with"
puts "#{User.last.email}"

puts "\nCreating a default support user"
puts "http://localhost:3000/supports/sign_in"
puts "user: support@worldcon.org"
puts "pass: 111111"

Support.create(
  email: "support@worldcon.org",
  password: 111111,
  confirmed_at: Time.now,
)

# Hugo setup
puts "Creating hugo categories"
FactoryBot.create(:category, :best_novel)
FactoryBot.create(:category, :best_novella)
FactoryBot.create(:category, :best_novelette)
FactoryBot.create(:category, :best_short_story)
FactoryBot.create(:category, :best_series)
FactoryBot.create(:category, :best_related_work)
FactoryBot.create(:category, :best_graphic_story_or_comic)
FactoryBot.create(:category, :best_dramatic_presentation_long_form)
FactoryBot.create(:category, :best_dramatic_presentation_short_form)
FactoryBot.create(:category, :best_professional_editor_short_form)
FactoryBot.create(:category, :best_professional_editor_long_form)
FactoryBot.create(:category, :best_professional_artist)
FactoryBot.create(:category, :best_semiprozine)
FactoryBot.create(:category, :best_fanzine)
FactoryBot.create(:category, :best_fancast)
FactoryBot.create(:category, :best_fan_writer)
FactoryBot.create(:category, :best_fan_artist)
FactoryBot.create(:category, :lodestar_award)
FactoryBot.create(:category, :astounding_award)
FactoryBot.create(:category, :retro_best_novel)
FactoryBot.create(:category, :retro_best_novella)
FactoryBot.create(:category, :retro_best_novelette)
FactoryBot.create(:category, :retro_best_short_story)
FactoryBot.create(:category, :retro_best_series)
FactoryBot.create(:category, :retro_best_related_work)
FactoryBot.create(:category, :retro_best_graphic_story_or_comic)
FactoryBot.create(:category, :retro_best_dramatic_presentation_long_form)
FactoryBot.create(:category, :retro_best_dramatic_presentation_short_form)
FactoryBot.create(:category, :retro_best_professional_editor_short_form)
FactoryBot.create(:category, :retro_best_professional_editor_long_form)
FactoryBot.create(:category, :retro_best_professional_artist)
FactoryBot.create(:category, :retro_best_semiprozine)
FactoryBot.create(:category, :retro_best_fanzine)
FactoryBot.create(:category, :retro_best_fancast)
FactoryBot.create(:category, :retro_best_fan_writer)
FactoryBot.create(:category, :retro_best_fan_artist)

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
