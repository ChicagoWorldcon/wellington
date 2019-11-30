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

class CreateElection < ActiveRecord::Migration[6.0]
  def up
    execute "DELETE FROM categories"
    create_table :elections do |t|
      t.column :name, :string, null: false
    end
    add_reference :categories, :election, index: true, null: false, foreign_key: true
  end

  def down
    remove_reference :categories, :election
    drop_table :elections
  end
end
