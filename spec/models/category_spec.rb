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
    :best_novel,
    :best_novella,
    :best_novelette,
    :best_short_story,
    :best_series,
    :best_related_work,
    :best_graphic_story_or_comic,
    :best_dramatic_presentation_long_form,
    :best_dramatic_presentation_short_form,
    :best_editor_short_form,
    :best_editor_long_form,
    :best_professional_artist,
    :best_semiprozine,
    :best_fanzine,
    :best_fancast,
    :best_fan_writer,
    :best_fan_artist,
    :lodestar_award,
    :astounding_award,
    :retro_best_novel,
    :retro_best_novella,
    :retro_best_novelette,
    :retro_best_short_story,
    :retro_best_series,
    :retro_best_related_work,
    :retro_best_graphic_story_or_comic,
    :retro_best_dramatic_presentation_long_form,
    :retro_best_dramatic_presentation_short_form,
    :retro_best_editor_short_form,
    :retro_best_editor_long_form,
    :retro_best_professional_artist,
    :retro_best_semiprozine,
    :retro_best_fanzine,
    :retro_best_fancast,
    :retro_best_fan_writer,
    :retro_best_fan_artist,
  ].each do |factory_type|
    it "can build valid #{factory_type}" do
      expect(create(:category, factory_type)).to be_valid
    end
  end

  describe "#fields" do
    it "has all 3 keys if present" do
      category = Category.new(
        field_1: "hey",
        field_2: "you",
        field_3: "get off of my cloud",
      )
      expect(category.fields.length).to eq(3)
      expect(category.fields).to include("field_3")
    end

    it "shows only 1 field if present" do
      category = Category.new(
        field_1: "hey",
      )
      expect(category.fields.length).to eq(1)
      expect(category.fields.first).to eq("field_1")
    end
  end
end
