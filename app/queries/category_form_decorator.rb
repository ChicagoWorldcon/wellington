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

class CategoryFormDecorator
  attr_reader :category, :nominations

  def initialize(category, nominations)
    @category = category
    @nominations = nominations
  end

  def heading
    "#{category.name} (#{count_complete} of #{Nomination::VOTES_PER_CATEGORY} complete)"
  end

  def accordion_classes
    case count_complete
    when 0
      "text-primary"
    else
      "text-dark"
    end
  end

  private

  def count_complete
    @count_complete ||= nominations.select(&:persisted?).count
  end
end
