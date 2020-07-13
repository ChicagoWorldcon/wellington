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




    # Configure the location of the en.yml file used for i18n translation such
    # that it will serve con-specific text.  Note that this will NOT override
    # the location used by outside gems, which is why devise.en.yml has to be
    # where it is.
    config.con_city = (ENV["WORLDCON_CITY"] || "wellington").downcase
<<<<<<< HEAD
    @city_folder = ENV["WORLDCON_CITY"].to_s.downcase
    config.i18n.load_path += Dir[Rails.root.join('config','locales', @city_folder, '*.{rb,yml}')]
=======
    config.i18n.load_path += Dir[Rails.root.join('config','locales', config.con_city, '*.{rb,yml}')]
>>>>>>> 50cdb1af04f80b55f30a705290e074470763d7a1

    # Configure the system model based on WORLDCON_CONTACT env var. This affects the DB.
    config.contact_model = (ENV["WORLDCON_CONTACT"] || "conzealand").downcase

    # Configure the site theme based on WORLDCON_THEME env var
    config.site_theme = (ENV["WORLDCON_THEME"] || "conzealand").downcase

    # Configure the name of the host city


    # Configure the pubic-facing name for the convention based on WORLDCON_PUBLIC_NAME env var
    config.con_public_name = (ENV["WORLDCON_PUBLIC_NAME"] || "wellington").downcase

    # Configure the year of the convention based on WORLDCON_YEAR env var
    config.con_year = (ENV["WORLDCON_YEAR"] || "2020")

    # Configure the email for help with Hugo issues
    config.hugo_help_email = (ENV["HUGO_HELP_EMAIL"] || "hugohelp@conzealand.nz")

    # Configure the default basic greeting
    config.basic_greeting = (ENV["GREETING"] || "wellington").downcase



    config.con_country = (ENV["WORLDCON_COUNTRY"] || "new zealand").downcase

    config.worldcon_volunteering_url = (ENV["WORLDCON_VOLUNTEERING_URL"] || "https://conzealand.nz/conzealand-needs").downcase

    config.worldcon_tos_url = (ENV["WORLDCON_TOS_URL"] || "https://conzealand.nz/about-conzealand/policies-and-expectations/" ).downcase

    config.worldcon_privacy_policy_url = (ENV["WORLDCON_PRIVACY_POLICY_URL"] || "https://conzealand.nz/privacy-policy/").downcase

    config.worldcon_homepage_url = (ENV["WORLDCON_HOMEPAGE_URL"] || "https://conzealand.nz/").downcase

    config.con_city_previous =
    (ENV["WORLDCON_CITY_PREVIOUS"] || "wellington").downcase

    config.wsfs_constitution = (ENV["WSF_CONSTITUTION_LINK"] || "http://www.wsfs.org/wp-content/uploads/2019/11/WSFS-Constitution-as-of-August-19-2019.pdf")

    #config.i18n.default_locale = (ENV["WORLDCON_CITY"] || "en").downcase.to_sym
    #config.i18n.fallbacks = [:en]
  end
end
