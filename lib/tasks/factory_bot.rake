# frozen_string_literal: true

# Copyright 2020 Victoria Garcia*
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
#
# *Adapted from the Thoughtbot docs for FactoryBot at:
# https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#linting-factories

namespace :factory_bot do
  desc "Verify that all FactoryBot factories are valid"
  task lint: :environment do
    factories_to_lint = FactoryBot.factories.select do |factory|
      factory.name =~ /(cart)/
    end
    if Rails.env.test?
      DatabaseCleaner.cleaning do
        FactoryBot.lint factories_to_lint, traits: true
      end
    else
      system("bundle exec rake factory_bot:lint RAILS_ENV='test'")
      fail if $?.exitstatus.nonzero?
    end
  end
end
