# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
# Copyright 2020 Victoria Garcia
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


require_relative "boot"
require_relative 'convention_details/detail_manager'
require "rails/all"


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Conzealand
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Disable asset pipeline, should all be moved to webpacker now
    config.assets.enabled = false
    config.generators { |g| g.assets false }

    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # https://edgeguides.rubyonrails.org/active_record_migrations.html#schema-dumping-and-you
    config.active_record.schema_format = :sql

    # Don't bother dumping a schema.rb file to avoid confusing extra files
    config.active_record.dump_schema_after_migration = false

    # Use sidekiq for jobs with #perform_later
    # Unless we're testing, then we'll end up with null mailers and aren't too worried
    # see https://github.com/mperham/sidekiq/wiki/Active-Job
    if !Rails.env.test?
      config.active_job.queue_adapter = :sidekiq
    end

    #Configures all convention-specific info
    config.convention_details = ConventionDetails::DetailManager.new.details

    if ENV["STRIPE_CURRENCY"].present?
      config.default_currency = ENV["STRIPE_CURRENCY"].downcase.to_sym
    else
      config.default_currency = :usd
    end

    # Configure the location of the en.yml file used for i18n translation such
    # that it will serve con-specific text.  Note that this will NOT override
    # the location used by outside gems, which is why devise.en.yml has to be
    # where it is.
    config.i18n.load_path += Dir[Rails.root.join('config','locales', config.convention_details.translation_folder, '*.{rb,yml}')]

    # Configure the system model based on WORLDCON_CONTACT env var. This affects the DB.
    config.contact_model = config.convention_details.contact_model

    # Configure the site theme based on WORLDCON_THEME env var
    config.site_theme = config.convention_details.site_theme

    # GNU Terry Pratchett
    config.middleware.use Rack::Pratchett

  end
end
