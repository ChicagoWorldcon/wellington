# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
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

# https://guides.rubyonrails.org/action_mailer_basics.html
unless Rails.env.development?
Rails.application.config.action_mailer.tap do |action_mailer|
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
