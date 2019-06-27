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

# While difficult to do, it is possible to bypass the application checks in some situations. Putting a unique constraint
# here stops errors fruther down the line.
#
# If this blows up on deploy we have a few things two worry about.
class AddUniqueConstraintToMembershipNumber < ActiveRecord::Migration[5.2]
  def change
    add_index :reservations, :membership_number, unique: true
  end
end
