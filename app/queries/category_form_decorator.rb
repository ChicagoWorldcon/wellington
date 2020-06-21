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

# CategoryFormDecorator is used for display in the top of Category forms in the NominationsController
# It tells you how many Nomination records you've saved and how many are left
# It handles display things like classes and colours
# Generally only 1 con will need this at a time, so you can go to town editing this ;-)
class CategoryFormDecorator
  attr_reader :category, :nominations

  def initialize(category, nominations)
    @category = category
    @nominations = nominations
  end

  def heading
    "#{category.name} (#{count_complete} of #{Nomination::VOTES_PER_CATEGORY} complete)"
  end

  def heading_id
    "heading-#{category.id}"
  end

  def accordion_classes
    [
      "card-header", # bootstrap asks for this
      "pointer",     # visual indicator that this is clickable
      text_colour,   # visual indicator for how 'complete' this category is
    ].join(" ")
  end

  private

  def text_colour
    case count_complete
    when 0
      "text-primary"
    else
      "text-dark"
    end
  end

  def count_complete
    @count_complete ||= nominations.select(&:persisted?).count
  end
end
