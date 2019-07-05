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

require "rails_helper"

RSpec.describe Category, type: :model do
  [
    :best_novel,
    :best_novella,
    :best_novelette,
    :best_short_story,
    :best_related_work,
    :best_graphic_story,
    :best_dramatic_presentation_long_form,
    :best_dramatic_presentation_short_form,
    :best_editor_long_form,
    :best_editor_short_form,
    :best_professional_artist,
    :best_semiprozine,
    :john_w_campbell_award,
  ].each do |factory_type|
    it "can build valid #{factory_type}" do
      expect(create(:category, factory_type)).to be_valid
    end
  end
end
