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

# Current goal
#
#         User -----------_
#        /    \            `.
#       /      \             `.
#      ^        ^              ^
#   Charge     Claim          Offer
#      v        v               v
#       \      /                |
#        \    /                 |
#       Purchase             Product
#            \                 /
#             \               /
#              `--< Order >--'

class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.references :purchase, null: false, foreign_key: true, index: true
      t.references :product, null: false, foreign_key: true, index: true
      t.datetime :active_from, null: false
      t.datetime :active_to
      t.timestamps
    end
  end
end
