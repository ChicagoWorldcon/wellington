# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 James Polley
# Copyright 2019 AJ Esler
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

namespace :dev do
  desc "Recreates database from master and seeds users"
  task napalm: %w(db:drop dev:bootstrap)

  desc "Asserts you've got everything for a running system, doesn't clobber"
  task bootstrap: %w(dev:setup:db dev:reset:schema db:migrate dev:setup:seeds)

  namespace :setup do
    desc "Recreates the database if there isn't one"
    task db: :environment do
      ActiveRecord::Base.establish_connection
      User.count
    rescue ActiveRecord::NoDatabaseError
      puts "Creating database and tables"
      Rake::Task["db:create"].invoke
      Rake::Task["db:schema:load"].invoke
    end

    desc "Seeds memberships"
    task seeds: :environment do
      if !Rails.env.development?
        puts "Skipping seeds, rails isn't running in developer mode"
        next
      end

      if User.count > 0
        puts "Database has been seeded"
        next
      end

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

      100.times do |count|
        puts "Seeding #{count} of 100 users" if count % 10 == 0
        new_user = FactoryBot.create(:user)
        memberships_held = rand(2..10)
        all_memberships.sample(memberships_held).each do |rando_membership|
          state = [Reservation::PAID, Reservation::INSTALMENT].sample

          reservation = FactoryBot.create(:reservation, user: new_user, membership: rando_membership, state: state)
        end
        new_user.active_claims.each do |claim|
          claim.update!(detail: FactoryBot.create(:detail, claim: claim))
        end
      end
    end
  end

  namespace :reset do
    desc "Sets db/schema.rb to the same as master"
    task :schema do
      system("git checkout origin/master db/schema.rb")
      system("git reset db/schema.rb")
    end
  end
end
