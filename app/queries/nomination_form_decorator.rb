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

# NominationFormDecorator has utility methods to display a Nomination as a form
# This helps primarily in layout of 1, 2 or 3 fields so it takes up the space without looking uncanny
class NominationFormDecorator < SimpleDelegator
  attr_reader :nomination, :category

  def initialize(nomination, category)
    @nomination = nomination
    @category = category
    super(nomination) # expose methods from nomination on this class
  end

  def column_classes
    case category.fields.count
    when 3
      "col-12 col-md-4"
    when 2
      "col-12 col-md-6"
    else
      "col-12"
    end
  end
end
