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
require_relative "convention"
require_relative "#{ENV["WORLDCON_NUMBER"]}"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.

module ConventionDetails
  class DetailManager
    attr_reader :details
    def initialize
      worldcon_number = (
        ENV["WORLDCON_NUMBER"] || abort("While there are optional configurations, WORLDCON_NUMBER isn't one. Set this.")
      ).strip
      convention_details_class = ConventionDetails.const_get(worldcon_number.capitalize)
      @details = convention_details_class.new
    end
  end
end
