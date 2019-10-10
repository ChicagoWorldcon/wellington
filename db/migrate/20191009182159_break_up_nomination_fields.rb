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

class BreakUpNominationFields < ActiveRecord::Migration[6.0]
  def change
    rename_column :nominations, :description, :field_1
    add_column :nominations, :field_2, :string, null: true
    add_column :nominations, :field_3, :string, null: true

    add_column :categories, :field_1, :string, null: false, default: "Nomination"
    add_column :categories, :field_2, :string, null: true
    add_column :categories, :field_3, :string, null: true
  end
end
