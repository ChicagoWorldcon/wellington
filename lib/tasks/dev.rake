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
  desc "Asserts you've got everything for a running system, doesn't clobber"
  task bootstrap: %w(dev:reset:structure dev:setup:db db:migrate db:seed:conzealand:development)

  desc "Runs update actions across dependencies"
  task :update do
    # Create update-deps branch, commit changes to lock files
    run!("bundle update")
    run!("rm -rf node_modules && yarn upgrade")
    run!("git commit -a -m 'maint: Upgrade all gems and npm modules'")

    # Push branch, check out where we were and delete branch
    current_branch = `git rev-parse --abbrev-ref HEAD`.chomp
    puts "Dependencies updated. Open a MR with this link:"
    puts "https://gitlab.com/worldcon/2020-wellington/merge_requests/new?merge_request[source_branch]=#{current_branch}&merge_request[force_remove_source_branch]=true"
  end

  namespace :setup do
    desc "Recreates the database, exits if we have users"
    task db: :environment do
      if napalm?
        puts "Napalm! Dropping database"
        Rake::Task["db:drop"].invoke
      end

      if database_state == :missing_database
        puts "Creating database and tables"
        Rake::Task["db:create"].invoke
        Rake::Task["db:structure:load"].invoke
      end
    rescue PG::ConnectionBad
      puts "Postgres connection bad, retrying..."
      sleep 1
      retry
    end
  end

  namespace :reset do
    desc "Sets db/structure.sql to the same as master"
    task :structure do
      system("git checkout --force origin/master db/structure.sql")
      system("git reset db/structure.sql")
    end
  end

  def run!(cmd)
    if !run(cmd)
      puts "Command failed: #{cmd}"
      exit(1)
    end

    true
  end

  def run(cmd)
    puts
    puts "> #{cmd}"
    system(cmd)
  end

  def napalm?
    case database_state
    when :missing_tables
      true # bad state, drop tables
    when :missing_database
      false # drop database will fail if not present
    else
      ENV["NAPALM"]&.match(/true/i)
    end
  end

  def database_state
    User.count
    :ready_to_rumble
  rescue PG::UndefinedTable
    :missing_tables
  rescue ActiveRecord::StatementInvalid
    :missing_database
  rescue ActiveRecord::NoDatabaseError
    :missing_database
  end
end
