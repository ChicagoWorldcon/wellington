# frozen_string_literal: true
#
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

class CreateCartItems < ActiveRecord::Migration[6.1]
  def change
    create_table :cart_items do |t|
      t.references :cart, index: true, null: false, foreign_key: true
      t.references :membership, index: true, null: false, foreign_key: true
      t.references :chicago_contact, index: true, null: false, foreign_key: true
      t.string :type, null:false
      t.boolean :later, null:false
      t.boolean :unavailable, null:true
      t.timestamps
    end
  end
end
