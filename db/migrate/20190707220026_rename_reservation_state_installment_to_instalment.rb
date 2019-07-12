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

class RenameReservationStateInstallmentToInstalment < ActiveRecord::Migration[5.2]
  def up
    execute %{
      UPDATE reservations SET state = 'instalment' WHERE state = 'installment'
    }
  end

  def down
    execute %{
      UPDATE reservations SET state = 'installment' WHERE state = 'instalment'
    }
  end
end
