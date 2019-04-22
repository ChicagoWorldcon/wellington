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

# Imports on v1.0 had $0 charges which may make confusing artifacts for our users. This is an attempt to fix it.
class DropZeroDollarCharges < ActiveRecord::Migration[5.2]
  def up
    imported_users = User.joins(:notes).where("notes.content LIKE ?", "Import%").distinct
    zero_dollar_imports = Charge.where(user_id: imported_users).where(amount: 0)
    puts "Destorying #{zero_dollar_imports.count} $0 charges"
    zero_dollar_imports.destroy_all
  end

  def down
    raise "Cannot reverse data migration"
  end
end
