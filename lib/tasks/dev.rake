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

namespace :dev do
  desc "Recreates database from master and seeds users"
  task napalm: %w(db:drop db:create dev:reset:schema db:schema:load db:migrate db:seed)

  namespace :generate do
    desc "Generates 100 random users and inserts them into the database"
    task users: :environment do
      100.times do |count|
        puts "Seeding #{count} of 100 users" if count % 10 == 0
        user = FactoryBot.create(:user, :with_purchase)
        user.active_claims.each do |claim|
          claim.update!(detail: FactoryBot.create(:detail, claim: claim))
        end
      end
    end
  end

  namespace :reset do
    desc "Sets db/schema.rb to the same as master"
    task :schema do
      system("git fetch")
      system("git checkout origin/master db/schema.rb")
      system("git reset db/schema.rb")
    end
  end
end
