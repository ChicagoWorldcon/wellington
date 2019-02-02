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

namespace :test do
  namespace :branch do
    desc "Finds all authors on the current branch"
    task :authors do
      @authors = `git log origin/master... --format="%an" | sort | uniq`.lines.map(&:chomp)
    end

    desc "Checks all authors in the branch have the correct copyrights"
    task copyright: :authors do
      exit_code = 0 # Pass on CI
      current_year = Date.today.year

      @authors.each do |author|
        authored_files = `git log origin/master... --name-only --author="#{author}" --format="" | sort | uniq`.lines.map(&:chomp)
        authored_files.each do |file|
          next if file.in?(%w(LICENSE db/schema.rb))
          next if file.match(/\.lock/)
          next if !FileTest.exist?(file)
          next if file.match("app/assets/images/")

          if File.readlines(file).grep(/Copyright #{current_year} .*#{author}/).none?
            exit_code = 1 # Fail on CI
            puts "Please add 'Copyright #{current_year} #{author}' to '#{file}'"
          end
        end
      end

      exit exit_code
    end

    desc "Checks all authors in the branch have updated the licence file"
    task license: :authors do
      exit_code = 0 # Pass on CI
      current_year = Date.today.year
      licence = File.readlines("LICENSE")

      @authors.each do |author|
        if licence.grep(/Copyright #{current_year} .*#{author}/).none?
          puts "Please add 'Copyright #{current_year} #{author}' to the LICENSE file"
        end
      end

      exit exit_code
    end
  end
end
