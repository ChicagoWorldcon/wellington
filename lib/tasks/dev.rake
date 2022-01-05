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

# ugh... no idea how to pull concerns in here
contact_name = (Rails.configuration.convention_details.contact_model || "chicago").downcase
seed_symbol = "db:seed:#{contact_name}:development"

namespace :dev do
  desc "Asserts you've got everything for a running system, doesn't clobber"
  task bootstrap: ["dev:reset:structure", "dev:setup:db", "db:migrate", seed_symbol]

  desc "Runs update actions across dependencies"
  task :update do
    # Create update-deps branch, commit changes to lock files
    run!("bundle update")
    run!("rm -rf node_modules && yarn upgrade")
    run!("git commit -a -m 'maint: Upgrade all gems and npm modules'")

    # Push branch, check out where we were and delete branch
    current_branch = `git rev-parse --abbrev-ref HEAD`.chomp
    puts "Dependencies updated. Open a MR with this link:"
    puts "https://gitlab.com/worldcon/wellington/merge_requests/new?merge_request[source_branch]=#{current_branch}&merge_request[force_remove_source_branch]=true"
  end

  task :changelog do
    changelog
  end

  task :release do
    raise "We can't run a release if there are staged changes." unless system("git diff --cached --quiet")

    release_name = Date.today.to_s
    releases_for_name = `git tag -l`.lines.select { |t| t =~ %r{release/#{release_name}} }.sort.map(&:chomp)
    release_count_str = ".#{releases_for_name.size + 1}" if releases_for_name.size > 0
    version = "#{release_name}#{release_count_str}"
    release_tag = "release/#{version}"
    changelog(version)
    raise "Unable to commit the changes" unless system("git commit --no-verify --message 'Changelog for #{version}'")
    raise "Could not tag" unless system("git tag #{release_tag}")
    raise "Could not push" unless system("git push origin #{release_tag}")
  end

  def changelog(version = nil)
    unless version
      # Generate a changelog using towncrier. If you don't have it installed, there's a whole thing involved around pip
      # and a Python virtualenv.
      tag = `git tag --points-at HEAD`.chomp.each_line.map do |line|
        %r{release/(.+)}.match(line) do |m|
          m[1]
        end
      end.compact.last

      unless tag
        puts "There are no tags pointing at the current revision. "
        puts "Tag this revision with `git tag release/<date>`"
        exit 1
      end

      version = tag
    end
    run!("towncrier --yes --name Wellington --version #{version}")
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
      system("git checkout --force origin/staging db/structure.sql")
      system("git reset db/structure.sql")
    end
  end

  def run!(cmd)
    unless run(cmd)
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
      ENV["NAPALM"]&.match(/true/i) # otherwise check to see if the user asked, could be true or false
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
