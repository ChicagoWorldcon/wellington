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

# Category represents a Hugo Award category
# see http://www.thehugoawards.org/hugo-categories/
class Category < ApplicationRecord
  belongs_to :election
  has_many :nominations
  has_many :finalists

  validates :description, presence: true
  validates :name, presence: true

  # Look up field_x in category where field_x is saved and not null
  # returns [:field_1, :field_2, :field_3]
  # Best author would have all 3 fields, best_semiprozine would have just field_1
  def fields
    return @fields if @fields.present?

    headings = attributes.slice("field_1", "field_2", "field_3")
    @fields = headings.compact.keys
  end

  def to_s
    name
  end
end
