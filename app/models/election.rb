# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
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

# Election represents a grouping of categories, nominations and balots depending on your con requirements.
# For instance, 'retro hugo' and 'hugo' are two groupings you could use to show two entirely separate pages for nomination and voting.
# And will route to Nominations for a Reservation tucked into the URL, e.g. https://members.conzealand.nz/reservations/123/nominations/retro_hugo
# i18n_key is used in those URL paths, i.e. a record with retro_hugo exists in 2020
# i18n_key is used to toggle the link displayed in from app/views/application/_reservation_card.html.erb
# Configure display of i18n values from config/locales/en.yml
class Election < ApplicationRecord
  has_many :categories

  validates :name, presence: true
  validates :i18n_key, presence: true, uniqueness: true
end
