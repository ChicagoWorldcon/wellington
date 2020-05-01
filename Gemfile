# frozen-string_literal: true

# Copyright 2019 AJ Esler
# Copyright 2019 James Polley
# Copyright 2019 Steven C Hartley
# Copyright 2019 Chris Rose
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

source "https://rubygems.org"

gem "bootsnap"             # boot large ruby/rails apps faster
gem "bundler-audit"        # checks for insecure gems
gem "devise"               # authentication solution for Rails with Warden
gem "gem-licenses"         # print libraries depended on by this project, grouped by licence
gem "jbuilder"             # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jwt"                  # pure ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT) standard
gem "money-rails"          # dealing with money and currency conversion in Rails
gem "octicons_helper"      # icon pack from github in a handy helper
gem "pg"                   # postgres driver
gem "puma"                 # http server for rack
gem "rails", "~> 6.0"      # framework for building websites <3
gem "redcarpet"            # markdown parser for displaying simple markup on text
gem "seedbank"             # For customizing seeds for all cons
gem "sidekiq"              # Background jobs processor
gem "sidekiq-scheduler"    # Background jobs processor scheduler
gem "stripe", "~> 4"       # payment provider, locked for https://github.com/rebelidealist/stripe-ruby-mock/pull/643
gem "tiny_tds"             # adapters for Dave's Hugo integration
gem "webpacker"            # a JavaScript module bundler, takes modules with dependencies and generates static assets

group :development, :test do
  gem "brakeman"                                      # vulnerability and static analysis
  gem "byebug", platforms: %i[mri mingw x64_mingw]    # Call "byebug" anywhere in the code for interactive debugging
  gem "capybara"                                      # Adds support for Capybara system testing and selenium driver
  gem "factory_bot_rails"                             # reusable model construction for tests
  gem "faker"                                         # fun common strings fro testing
  gem "guard-rspec", require: false                   # tests that re-run on save are nice
  gem "pry"                                           # nicer debugger, use 'binding.pry'
  gem "pry-nav"                                       # adds 'step' and 'next' to pry
  gem "rspec-rails"                                   # testing framework
  gem "rubocop"                                       # linting for idiomatic ruby
  gem "rubocop-performance"                           # performance static analysis
  gem "rubocop-rails"                                 # linting for idiomatic rails
  gem "rubocop-rspec"                                 # linting for idiomatic rspec
  gem "ruby_audit"                                    # checks for CVEs affecting Ruby and RubyGems
  gem "selenium-webdriver"                            # brower based full stack testing
  gem "simplecov"                                     # tracks test coverage
  gem "stripe-ruby-mock", require: "stripe_mock"      # fake stripe responses for testing
  gem "timecop"                                       # time travel for specs
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"       # watch and reload files when they change
  gem "pry-rails"                         # sets pry as your rails console
  gem "spring"                            # keeps track of files, only recompiles what's hcanged
  gem "spring-watcher-listen", "~> 2.0.0" # smarter hooks for spring, stops filessytem polling
  gem "web-console", ">= 3.3.0"           # access an IRB console on exception pages or with <%= console %> in code
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Suggested gems, investigate later
# gem "therubyracer", platforms: :ruby # See https://github.com/rails/execjs#readme for more supported runtimes
# gem "redis", "~> 4.0" # Use Redis adapter to run Action Cable in production
# gem "bcrypt", "~> 3.1.7" # Use ActiveModel has_secure_password
