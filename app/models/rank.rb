# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
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

# Rank represents a ranked choice in votes for the Hugo Awards
# A User creates a rank through their Reservation for a Finalist in a Category
# Validations about duplciate ranks are higher level than this
# But you should only be able to at most submit one rank on a Reservation per Finalist
class Rank < ApplicationRecord
  belongs_to :finalist
  belongs_to :reservation

  # validate :position_unique_in_category

  validates :finalist, uniqueness: { scope: :reservation }
  validates :position, presence: true

  private

  def position_unique_in_category
    finalists_in_category = Finalist.where(category_id: finalist.category_id)

    positions_in_category = Rank.where(
      position: position,
      reservation_id: reservation_id,
      finalist_id: finalists_in_category,
    )

    positions_in_category.where.not(id: id).exists?
  end
end
