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
require_relative 'convention_details/convention'
require_relative 'convention_details/chicago'
require "rails/all"
require 'pry'


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

    # Configure the name of the host city
    config.worldcon_number = (ENV["WORLDCON_NUMBER"] || "80").strip

    # Configure the location of the en.yml file used for i18n translation such
    # that it will serve con-specific text.  Note that this will NOT override
    # the location used by outside gems, which is why devise.en.yml has to be
    # where it is.
    @con_translation_folder = "worldcon" + config.worldcon_number
    config.i18n.load_path += Dir[Rails.root.join('config','locales', @con_translation_folder, '*.{rb,yml}')]

    # Convention-specific details that are not required for the actual
    # configuration process come in here.
    config.convention_details = ConventionDetails::Chicago.new
    #config.i18n.default_locale = (ENV["WORLDCON_CITY"] || "en").downcase.to_sym
    #config.i18n.fallbacks = [:en]

    # Configure the system model based on WORLDCON_CONTACT env var. This affects the DB.
    config.contact_model = (ENV["WORLDCON_CONTACT"] || "conzealand").downcase

    # Configure the site theme based on WORLDCON_THEME env var
    config.site_theme = (ENV["WORLDCON_THEME"] || "conzealand").downcase



  end
end
