# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
# Copyright 2020 Victoria Garcia
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

# Based on a comment from Nicholas who said we "...do need to keep to the constitutional order"
Category.transaction do
  ordered_categories = [
    "Best Novel",
    "Best Novella",
    "Best Novelette",
    "Best Short Story",
    "Best Series",
    "Best Related Work",
    "Best Graphic Story or Comic",
    "Best Dramatic Presentation, Long Form",
    "Best Dramatic Presentation, Short Form",
    "Best Editor, Short Form",
    "Best Editor, Long Form",
    "Best Professional Artist",
    "Best Semiprozine",
    "Best Fanzine",
    "Best Fancast",
    "Best Fan Writer",
    "Best Fan Artist",
    "Lodestar Award for Best Young Adult Book (not a Hugo)",
    "Astounding Award for the best new science fiction writer, sponsored by Dell Magazines (not a Hugo)",
  ]

  ordered_categories.each.with_index(1) do |category_name, n|
    Category.find_by!(name: category_name).update!(order: n)
  end

  ordered_retro_categories = [
    "Retro Best Novel",
    "Retro Best Novella",
    "Retro Best Novelette",
    "Retro Best Short Story",
    "Retro Best Series",
    "Retro Best Related Work",
    "Retro Best Graphic Story or Comic",
    "Retro Best Dramatic Presentation, Long Form",
    "Retro Best Dramatic Presentation, Short Form",
    "Retro Best Editor, Short Form",
    "Retro Best Editor, Long Form",
    "Retro Best Professional Artist",
    "Retro Best Semiprozine",
    "Retro Best Fanzine",
    "Retro Best Fancast",
    "Retro Best Fan Writer",
    "Retro Best Fan Artist",
  ]

  ordered_retro_categories.each.with_index(100) do |category_name, n|
    Category.find_by!(name: category_name).update!(order: n)
  end
end
