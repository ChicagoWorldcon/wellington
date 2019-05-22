# frozen-string_literal: true

# Copyright 2019 AJ Esler
# Copyright 2019 Matthew B. Gray
# Copyright 2019 James Polley
# Copyright 2019 Steven C Hartley
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

gem "devise"               # authentication solution for Rails with Warden
gem "jbuilder"             # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jwt"                  # pure ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT) standard
gem "markerb"              # Renders Html and Text email from Markdown template
gem "pg"                   # postgres driver
gem "puma"                 # http server for rack
gem "rails", "5.2.3"       # framework for building websites <3
gem "redcarpet"            # parser for markerb
gem "sassc-rails"          # sass compiler, an easier way to manage styles
gem "stripe"               # payment provider
gem "uglifier"             # for minifying javascript and css

group :development, :test do
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw] # Call "byebug" anywhere in the code for interactive debugging
  gem "capybara"                                      # Adds support for Capybara system testing and selenium driver
  gem "factory_bot_rails"                             # reusable model construction for tests
  gem "faker"                                         # fun common strings fro testing
  gem "pry"                                           # nicer debugger, use 'binding.pry'
  gem "pry-nav"                                       # adds 'step' and 'next' to pry
  gem "rspec-rails"                                   # testing framework
  gem "rubocop", "0.66.0"                             # FIXME pin to stop namespace warnings
  gem "rubocop-github"                                # ruby ilnting to keep things clean
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
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

# Suggested gems, investigate later
gem "therubyracer", platforms: :ruby # See https://github.com/rails/execjs#readme for more supported runtimes
# gem "redis", "~> 4.0" # Use Redis adapter to run Action Cable in production
# gem "bcrypt", "~> 3.1.7" # Use ActiveModel has_secure_password
