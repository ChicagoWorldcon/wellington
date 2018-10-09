# frozen-string_literal: true

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

source "https://rubygems.org"

gem "gibbon"
gem "jbuilder", "~> 2.5" # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "pg"
gem "puma", "~> 3.7"
gem "rails", "~> 5.1.6"
gem "sass-rails", "~> 5.0"
gem "sqlite3"
gem "stripe"
gem "turbolinks", "~> 5"
gem "uglifier", ">= 1.3.0"

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw] # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "capybara", "~> 2.13" # Adds support for Capybara system testing and selenium driver
  gem "rspec-rails"
  gem "rubocop-github"
  gem "selenium-webdriver"
  gem "stripe-ruby-mock", require: "stripe_mock"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "pry"
  gem "pry-nav"
  gem "rails-pry"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0" # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Suggested gems, investigate later
# gem "therubyracer", platforms: :ruby # See https://github.com/rails/execjs#readme for more supported runtimes
# gem "redis", "~> 4.0" # Use Redis adapter to run Action Cable in production
# gem "bcrypt", "~> 3.1.7" # Use ActiveModel has_secure_password
