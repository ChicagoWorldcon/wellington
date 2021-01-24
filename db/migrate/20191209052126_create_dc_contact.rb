# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2021 Fred Bauer
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

# Modified for DC because we can't create dc_contacts since it already exists.
# More working through bad automation design.

# Based initially off https://reg.discon3.org/reg/
class CreateDcContact < ActiveRecord::Migration[6.0]
  def change
    # Initial model based on Conzealand contact form, can be modified
    create_table :unused_contacts, force: :cascade do |t|
      t.references :claim, null: false, index: true

      t.string "import_key"

      t.string "title"
      t.string "first_name"
      t.string "last_name"
      t.string "preferred_first_name"
      t.string "preferred_last_name"

      t.string "badge_subtitle"
      t.string "badge_title"

      t.string "address_line_1"
      t.string "address_line_2"
      t.string "city"
      t.string "country"
      t.string "postal"
      t.string "province"

      t.string "publication_format"

      t.boolean "interest_accessibility_services"
      t.boolean "interest_being_on_program"
      t.boolean "interest_dealers"
      t.boolean "interest_exhibiting"
      t.boolean "interest_performing"
      t.boolean "interest_selling_at_art_show"
      t.boolean "interest_volunteering"

      t.boolean "share_with_future_worldcons", default: true
      t.boolean "show_in_listings", default: true

      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
  end
end
