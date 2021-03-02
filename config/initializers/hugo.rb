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

# ENV["HUGO_NOMINATIONS_OPEN_FROM="2019-07-16T00:00:00+1200"
# ENV["HUGO_VOTING_OPEN_FROM="2019-08-16T00:00:00+1200"
# ENV["HUGO_CLOSED_AT="2020-08-02T12:00:00+1200"

class SetHugoGlobals
  RUNNING_IN_CI = ENV["GITLAB_CI_RUNNING"].present? || ENV["CI"] == "true"
  HUGO_GLOBALS_NEEDED = !RUNNING_IN_CI && Rails.env.production?

  def call
    $nomination_opens_at = time_from("HUGO_NOMINATIONS_OPEN_AT") || DateTime.now
    $voting_opens_at = time_from("HUGO_VOTING_OPEN_AT") || 1.day.from_now
    $hugo_closed_at = time_from("HUGO_CLOSED_AT") || 2.weeks.from_now
  end

  private

  def time_from(lookup)
    time_string = ENV[lookup]
    assert_present_on_production!(time_string, lookup)
    parse!(time_string, lookup) if time_string.present?
  end

  def assert_present_on_production!(time_string, lookup)
    if time_string.nil? && HUGO_GLOBALS_NEEDED
      puts
      puts "Missing requried environment variable #{lookup}"
      puts "Please check your .env"
      puts
      exit 1
    end
  end

  def parse!(time_string, lookup)
    DateTime.parse(time_string)
  rescue
    puts
    puts "Cannot parse time from #{lookup}=#{time_string}"
    puts "Please check your .env"
    puts
    exit 1 if !RUNNING_IN_CI && Rails.env.production?
  end
end

SetHugoGlobals.new.call
