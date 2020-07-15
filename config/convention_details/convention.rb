# frozen_string_literal: true

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

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

module ConventionDetails

  class Convention
    class_attribute :con_city
    class_attribute :con_city_previous
    class_attribute :con_country
    class_attribute :con_country_previous
    class_attribute :con_dates_informal_end
    class_attribute :con_dates_informal_start
    class_attribute :con_greeting_basic
    class_attribute :con_hugo_download_A4
    class_attribute :con_hugo_download_letter
    class_attribute :con_name_public
    class_attribute :con_name_public_previous
    class_attribute :con_number
    class_attribute :con_organizers_sigs
    class_attribute :con_url_homepage
    class_attribute :con_url_member_login
    class_attribute :con_url_privacy
    class_attribute :con_url_tos
    class_attribute :con_url_volunteering
    class_attribute :con_wsfs_constitution_link
    class_attribute :con_year
    class_attribute :contact_model
    class_attribute :site_theme
    class_attribute :translation_folder
  end
end
