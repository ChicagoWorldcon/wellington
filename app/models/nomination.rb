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

class Nomination < ApplicationRecord
  VOTES_PER_CATEGORY = 5

  belongs_to :category
  belongs_to :reservation

  # We don't want blank models, it's clutter
  validate :at_least_one_field

  def to_s
    fields_set = [field_1, field_2, field_3].select(&:present?)
    fields_set.join("; ")
  end

  private

  def at_least_one_field
    if [field_1, field_2, field_3].none?(&:present?)
      errors.add(:field_1, "must specify at least one field")
      errors.add(:field_2, "must specify at least one field")
      errors.add(:field_3, "must specify at least one field")
    end
  end
end
