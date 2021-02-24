# frozen_string_literal: true
#
# Copyright 2021 Victoria Garcia
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

class UsePolymorphicAssociationInCharge < ActiveRecord::Migration[6.1]
  def up
    add_reference :charges, :buyable, polymorphic: true, index: true, null: true
    Charge.update_all("buyable_id = reservation_id, buyable_type = 'Reservation'")
    remove_reference :charges, :reservation, index: true, foreign_key: true
  end

  def down
    add_reference :charges, :reservation, index: true, foreign_key: true, null: true
    Charge.update_all("reservation_id = buyable_id")
    change_column_null :charges, :reservation_id, :false
    remove_reference :charges, :buyable, polymorphic: true, index: true, null: true
  end
end
