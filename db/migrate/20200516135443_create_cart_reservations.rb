# frozen_string_literal: true

# Copyright 2020 Chris Rose
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

# Create the table linking cards with reservations
class CreateCartReservations < ActiveRecord::Migration[6.0]
  def change
    create_table :cart_reservations do |t|
      t.belongs_to :cart
      t.belongs_to :reservation
      t.timestamps
    end
  end
end
