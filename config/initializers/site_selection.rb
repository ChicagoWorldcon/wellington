# frozen_string_literal: true

# Copyright 2022 Chris Rose
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

class SiteSelectionGlobals
  RUNNING_IN_CI = ENV["GITLAB_CI_RUNNING"].present? || ENV["CI"] == "true"
  SITE_SELECTION_GLOBALS_NEEDED = !RUNNING_IN_CI && Rails.env.production?

  def call
    worldcon_link = config_from("SITE_SELECTION_WORLDCON_LINK") || "http://localhost:3000/"
    nasfic_link = config_from("SITE_SELECTION_NASFIC_LINK") || "http://localhost:3000/"
    worldcon_price = (config_from("SITE_SELECTION_WORLDCON_PRICE") || "5000").to_i
    nasfic_price = (config_from("SITE_SELECTION_NASFIC_PRICE") || "3000").to_i

    $site_selection_info = {
      "worldcon" => {
        link: worldcon_link,
        price: worldcon_price
      },
      "nasfic" => {
        link: nasfic_link,
        price: nasfic_price
      }
    }
  end

  private

  def config_from(envvar)
    config_value = ENV[envvar]
    assert_present_on_production!(config_value, envvar)
  end

  def assert_present_on_production!(config_value, lookup)
    if config_value.nil? && SITE_SELECTION_GLOBALS_NEEDED
      puts
      puts "Missing requried environment variable #{lookup}"
      puts "Please check your .env"
      puts
      exit 1
    end
  end
end

SiteSelectionGlobals.new.call
