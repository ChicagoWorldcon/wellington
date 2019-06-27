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

# Update the charges table to use the Rails Money gem
# See https://github.com/RubyMoney/money-rails
class AddMonetizeToCharges < ActiveRecord::Migration[5.2]
  def up
    add_monetize :charges, :amount
    execute "UPDATE charges SET amount_cents = amount"
    remove_column :charges, :amount
  end

  def down
    add_column :charges, :amount, :integer
    execute "UPDATE charges SET amount = amount_cents"
    remove_monetize :charges, :amount
    change_column_null(:charges, :amount, false)
  end
end
