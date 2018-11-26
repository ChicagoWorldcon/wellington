# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
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

class CreateDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :details do |t|
      t.references :claim, null: false, index: true

      t.string :import_key

      t.string :full_name, null: false
      t.string :preferred_first_name
      t.string :prefered_last_name
      t.string :badgetitle
      t.string :badgesubtitle

      t.string :address_line_1, null: false
      t.string :address_line_2
      t.string :city
      t.string :province
      t.string :postal
      t.string :country, null: false

      t.string :publication_format

      t.boolean :show_in_listings
      t.boolean :share_with_future_worldcons
      t.boolean :interest_volunteering
      t.boolean :interest_accessibility_services
      t.boolean :interest_being_on_program
      t.boolean :interest_dealers
      t.boolean :interest_selling_at_art_show
      t.boolean :interest_exhibiting
      t.boolean :interest_performing

      t.timestamps
    end
  end
end
