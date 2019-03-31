# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 James Polley
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

namespace :test do
  namespace :branch do
    desc "Checks all authors in the branch have the correct copyrights"
    task :copyright do
      clear_attribution = true # Pass on CI
      current_year = Date.today.year
      authors = `git log origin/master... --format="%an" | sort | uniq`.lines.map(&:chomp)

      errors = []

      # Check to see files authored by people in the branch contain their Git usernames
      authors.each do |author|
        authored_files = `git log origin/master... --name-only --author="#{author}" --format="" | sort | uniq`.lines.map(&:chomp)
        authored_files.each do |file|
          next if file.match(/LICENSE/)
          next if file.match(/schema.rb$/)
          next if file.match(/\.ruby-version$/)
          next if file.match(/\.lock$/)
          next if file.match(/\.md$/)
          next if file.match("app/assets/images/")
          next if !FileTest.exist?(file)

          if File.readlines(file).grep(/Copyright #{current_year} .*#{author}/).none?
            clear_attribution = false # Fail on CI
            errors << "Missing 'Copyright #{current_year} #{author}' from '#{file}'"
          end
        end
      end

      # Special case file, if you work in this repository, you need to make sure you mention our name in the LICENSE and
      # README.md with the current year.
      %w(LICENSE README.md).each do |file_name|
        lines = File.readlines(file_name)
        authors.each do |author|
          if lines.grep(/Copyright #{current_year} .*#{author}/).none?
            clear_attribution = false
            errors "Missing 'Copyright #{current_year} #{author}' in #{file_name} file"
          end
        end
      end

      if errors.any?
        puts "This project is distributed under an Apache licence"
        puts "We need clear attribution in order to be able to accept work from other people"
        puts "For more information, please check out our contribution guidelines"
        puts "https://gitlab.com/worldcon/2020-wellington/blob/master/CONTRIBUTING.md"
        puts
        puts "This is based on your git commit name"
        puts "You can change this for this repsitory by running:"
        puts
        puts "    git config user.name \"Your Full Name\""
        puts
        puts "or in all your git projects with"
        puts
        puts "    git config --global user.name \"Your Full Name\""
        puts

        errors.each do |error|
          puts error
        end

        exit 1 # Fails CI
      end
    end
  end
end
