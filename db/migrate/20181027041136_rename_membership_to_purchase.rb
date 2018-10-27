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

class RenameMembershipToPurchase < ActiveRecord::Migration[5.1]
  # Rails doesn't rename foreign keys for you, so we have to do these steps manually
  def change
    remove_foreign_key :claims,  :memberships
    remove_foreign_key :charges, :memberships
    rename_column      :claims,  :membership_id, :purchase_id
    rename_column      :charges, :membership_id, :purchase_id

    rename_table :memberships, :purchases

    add_foreign_key :claims,  :purchases, index: true
    add_foreign_key :charges, :purchases, index: true
  end
end
