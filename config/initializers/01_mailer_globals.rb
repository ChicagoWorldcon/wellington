# frozen_string_literal: true

#
# Copyright (c) 2022 Chris Rose
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

if Rails.env.production?
  %w[MAINTAINER_EMAIL MEMBER_SERVICES_EMAIL HUGO_HELP_EMAIL].each do |env_var|
    next if ENV[env_var].present?

    begin
      puts "Please set #{env_var} in production"
      exit 1
    end
  end
end

# FIXME: by adding the correct email addresses before this goes into production
$maintainer_email = ENV.fetch(
  "MAINTAINER_EMAIL",
  "maintainer@localhost"
).downcase

$member_services_email = ENV.fetch(
  "MEMBER_SERVICES_EMAIL",
  "member_services@localhost"
).downcase

# FIXME: I know this is a lousy hack. I plan to revisit the emails soon and make a con-config setup for them.
$treasurer_email = ENV.fetch(
  "TREASURER_EMAIL",
  "treasurer@chicon.org"
).downcase

$hugo_help_email = ENV.fetch(
  "HUGO_HELP_EMAIL",
  "hugo_help@localhost"
).downcase

if Rails.env.production? && ENV["HUGO_HELP_EMAIL"].nil?
  puts "Please set HUGO_HELP_EMAIL to allow for reply address on report emails"
  exit 1
end

# If these are not set, they're basically disabled
$nomination_reports_email = ENV["NOMINATION_REPORTS_EMAIL"]&.downcase
$membership_reports_email = ENV["MEMBERSHIP_REPORTS_EMAIL"]&.downcase
