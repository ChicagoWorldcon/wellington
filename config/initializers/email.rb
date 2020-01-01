# frozen_string_literal: true

# Copyright 2019 Steven C Hartley
# Copyright 2020 Matthew B. Gray
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

Rails.application.config.action_mailer.tap do |action_mailer|
  if Rails.env.development?
    # Advice from rails g devise:install
    action_mailer.default_url_options = { host: "localhost", port: 3000 }

    # hook into mailcatcher
    action_mailer.delivery_method = :smtp
    inside_docker = File.exist?("/.dockerenv")
    if inside_docker
      # mailcatcher running in another container defined in docker-compose.yml
      action_mailer.smtp_settings = { address: "mail", port: 1025 }
    else
      # mailcatcher running in backgrounded process
      action_mailer.smtp_settings = { address: "0.0.0.0", port: 1025 }
    end


    # Mailer previews for rspec
    # see https://stackoverflow.com/a/39204340/81271
    # preview on http://localhost:3000/rails/mailers
    action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"
  elsif Rails.env.test?
    action_mailer.default_url_options = {
      host: "localhost"
    }
  else
    # Setup SMTP
    # https://guides.rubyonrails.org/action_mailer_basics.html
    action_mailer.delivery_method = :smtp
    action_mailer.tap do |action_mailer|
      action_mailer.raise_delivery_errors = true
      action_mailer.smtp_settings = {
        address:              ENV["SMTP_SERVER"],
        port:                 ENV["SMTP_PORT"],
        user_name:            ENV["SMTP_USER_NAME"],
        password:             ENV["SMTP_PASSWORD"],
        authentication:       "plain",
        enable_starttls_auto: true
      }
    end
  end

  $member_services_email = ENV.fetch(
    "MEMBER_SERVICES_EMAIL",
    "registrations@conzealand.nz"
  ).downcase

  if Rails.env.production? && ENV["MEMBER_SERVICES_EMAIL"].nil?
    puts "Please set MEMBER_SERVICES_EMAIL to show where system emails come from"
    exit 1
  end
end
