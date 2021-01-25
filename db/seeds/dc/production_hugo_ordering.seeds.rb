# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
# Copyright 2020 Victoria Garcia
# Copyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");

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
    "Best Video Game",
    "Lodestar Award for Best Young Adult Book (not a Hugo)",
    "Astounding Award for the Best New Writer, sponsored by Dell Magazines (not a Hugo)",
  ]

  ordered_categories.each.with_index(1) do |category_name, n|
    Category.find_by!(name: category_name).update!(order: n)
  end
end
