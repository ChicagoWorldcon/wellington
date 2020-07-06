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

FactoryBot.define do
  factory :election do
    name { "Hugo" }
    i18n_key { "hugo" }

    trait :retro do
      name { "Retro Hugo" }
      i18n_key { "retro_hugo" }
    end

    trait :with_categories do
      after(:build) do |new_election, _evaluator|
        new_election.categories = [
          build(:category, :best_novel, election: new_election),
          build(:category, :best_novel, election: new_election),
          build(:category, :best_novella, election: new_election),
          build(:category, :best_novelette, election: new_election),
          build(:category, :best_short_story, election: new_election),
          build(:category, :best_series, election: new_election),
          build(:category, :best_related_work, election: new_election),
          build(:category, :best_graphic_story_or_comic, election: new_election),
          build(:category, :best_dramatic_presentation_long_form, election: new_election),
          build(:category, :best_dramatic_presentation_short_form, election: new_election),
          build(:category, :best_editor_short_form, election: new_election),
          build(:category, :best_editor_long_form, election: new_election),
          build(:category, :best_professional_artist, election: new_election),
          build(:category, :best_semiprozine, election: new_election),
          build(:category, :best_fanzine, election: new_election),
          build(:category, :best_fancast, election: new_election),
          build(:category, :best_fan_writer, election: new_election),
          build(:category, :best_fan_artist, election: new_election),
          build(:category, :lodestar_award, election: new_election),
          build(:category, :astounding_award, election: new_election),
        ]
      end
    end
  end
end
