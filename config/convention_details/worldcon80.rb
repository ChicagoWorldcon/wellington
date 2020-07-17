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
require "date"
require_relative "convention"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
module ConventionDetails
  class Worldcon80 < ConventionDetails::Convention

    attr_reader  :con_city, :con_city_previous, :con_country, :con_country_previous, :con_datews_informal_end, :con_dates_informal_start, :con_greeting_basic, :con_hugo_download_A4, :con_hugo_download_letter, :con_name_public, :con_name_public_previous, :con_number, :con_organizers_sigs, :con_url_homepage, :con_url_member_login, :con_url_privacy, :con_url_tos, :con_url_volunteering, :con_wsfs_constitution_link, :con_year, :contact_model, :site_theme, :translation_folder

    def initialize
      super
      @con_city = "Chicago"
      @con_city_previous = "Washington, D. C."
      @con_country = "The USA"
      @con_country_previous = "The USA"
      @con_dates_informal_end = "Monday, September 5th"
      @con_dates_informal_start = "Wednesday, August 31st"
      @con_greeting_basic = "greetings"
      #FIXME: Update hugo ballot locations when we have them
      @con_hugo_download_A4 = "https://www.wsc.edu/download/downloads/id/1843/chicago_citation_style_examples_-_17th_edition.pdf"
      @con_hugo_download_letter = "https://www.wsc.edu/download/downloads/id/1843/chicago_citation_style_examples_-_17th_edition.pdf"
      @con_name_public = "Tasfic II"
      @con_name_public_previous = "DisCon 3"
      @con_number = "worldcon80"
      #FIXME: Update @con_organizers_sigs
      @con_organizers_sigs = "Helen Montgomery & co-conspirators"
      #FIXME: Verify ALL Chicon  Urls
      @con_url_homepage = "http://chicon.org/"
      @con_url_member_login = "https://registration.chicon.org/"
      @con_url_privacy = "http://chicon.org/privacy.php"
      @con_url_tos = "http://chicon.org/code-of-conduct.php"
      @con_url_volunteering = "http://chicon.org/volunteers.php"
      #FIXME: After CoNZealand, update WSFS constitution link
      @con_wsfs_constitution_link = "=http://www.wsfs.org/wp-content/uploads/2019/11/WSFS-Constitution-as-of-August-19-2019.pdf"
      @con_year = "2022"
      @contact_model = "chicago"
      @site_theme = "chicago"
      @translation_folder = "chicago"
    end
  end
end
