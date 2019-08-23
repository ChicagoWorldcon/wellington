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
  task bootstrap: %w(dev:setup:db dev:reset:schema db:migrate db:seed:development:conzealand)

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
  end

  namespace :reset do
    desc "Sets db/schema.rb to the same as master"
    task :schema do
      system("git checkout origin/master db/schema.rb")
      system("git reset db/schema.rb")
    end
  end
end
