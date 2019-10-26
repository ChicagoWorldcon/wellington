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
  task bootstrap: %w(dev:reset:structure dev:setup:db db:migrate db:seed:conzealand:development)

  desc "Runs update actions across dependencies"
  task :update do
    # Create update-deps branch, commit changes to lock files
    run!("git checkout -b update-deps origin/master")
    run!("bundle update")
    run!("yarn upgrade")
    run!("git commit -a -m 'maint: Upgrade all gems and npm modules'")

    # Push branch, check out where we were and delete branch
    run!("git push -f -u origin update-deps")
    run!("git checkout -")
    run!("git branch -d update-deps")
    puts "Dependencies updated. Open a MR with this link:"
    puts "https://gitlab.com/worldcon/2020-wellington/merge_requests/new?merge_request[source_branch]=update-deps&merge_request[force_remove_source_branch]=true"
  end

  namespace :setup do
    desc "Recreates the database if there isn't one"
    task db: :environment do
      retries ||= 0
      ActiveRecord::Base.establish_connection
      User.count
    rescue ActiveRecord::NoDatabaseError
      puts "Creating database and tables"
      Rake::Task["db:create"].invoke
      Rake::Task["db:structure:load"].invoke
    rescue
      # If we fail for any other reason, try again in a moment
      sleep 1
      if (retries += 1) < 3
        puts "Trying again..."
        retry
      end
    end
  end

  namespace :reset do
    desc "Sets db/structure.sql to the same as master"
    task :structure do
      system("git checkout origin/master db/structure.sql")
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
end
