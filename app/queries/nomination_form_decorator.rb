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

# Utility methods in service of displaying a nomination on the Nominations form
class NominationFormDecorator < SimpleDelegator
  attr_reader :nomination, :category

  def initialize(nomination, category)
    @nomination = nomination
    @category = category
    super(nomination) # expose methods from nomination on this class
  end

  def column_classes
    case fields.count
    when 3
      "col-12 col-md-4"
    else
      "col-12 col-md-6"
    end
  end

  # Look up field_x in category where field_x is saved and not null
  # returns [:field_1, :field_2, :field_3]
  # Best author would have all 3 fields, best_semiprozine would have just field_1
  def fields
    return @fields if @fields.present?

    category_headings = category.attributes.slice("field_1", "field_2", "field_3")
    present_headings = category_headings.compact.keys
    @fields = present_headings
  end
end
