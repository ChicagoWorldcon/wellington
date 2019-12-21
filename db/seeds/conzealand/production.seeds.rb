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

presupport_open = "2004-09-06".to_time
con_announced = "2018-08-25".to_time
price_change_1 = "2019-06-16 23:59:59 NZDT".to_time
dublin_import = "2019-12-01".to_time

########################################
# Presupport membership types

Membership.create!(
  "name": "silver_fern",
  "active_from": presupport_open,
  "active_to": con_announced,
  "description": "Presupport membership",
  "can_vote": false,
  "can_nominate": false,
  "can_attend": false,
  "price": Money.new(32000),
)
Membership.create!(
  "name": "kiwi",
  "active_from": presupport_open,
  "active_to": con_announced,
  "description": "Presupport membership",
  "can_vote": false,
  "can_nominate": false,
  "can_attend": false,
  "price": Money.new(5000),
)
Membership.create!(
  "name": "tuatara",
  "active_from": presupport_open,
  "active_to": con_announced,
  "description": "Presupport membership",
  "can_vote": false,
  "can_nominate": false,
  "can_attend": false,
  "price": Money.new(0),
)
Membership.create!(
  "name": "pre_oppose",
  "active_from": presupport_open,
  "active_to": con_announced,
  "description": "Presupport membership",
  "can_vote": false,
  "can_nominate": false,
  "can_attend": false,
  "price": Money.new(0),
)
Membership.create!(
  "name": "pre_support",
  "active_from": presupport_open,
  "active_to": con_announced,
  "description": "Presupport membership",
  "can_vote": false,
  "can_nominate": false,
  "can_attend": false,
  "price": Money.new(0),
)

########################################
# Con membership types

Membership.create!(
  "name": "adult",
  "active_from": con_announced,
  "active_to": price_change_1,
  "description": nil,
  "can_vote": true,
  "can_nominate": true,
  "can_attend": true,
  "price": Money.new(37000),
)
Membership.create!(
  "name": "adult",
  "active_from": price_change_1,
  "active_to": nil,
  "description": nil,
  "can_vote": true,
  "can_nominate": true,
  "can_attend": true,
  "price": Money.new(40000),
)

Membership.create!(
  "name": "young_adult",
  "active_from": con_announced,
  "active_to": price_change_1,
  "description": "born in or after 2000",
  "can_vote": true,
  "can_nominate": true,
  "can_attend": true,
  "price": Money.new(22500),
)
Membership.create!(
  "name": "young_adult",
  "active_from": price_change_1,
  "active_to": nil,
  "description": "born in or after 2000",
  "can_vote": true,
  "can_nominate": true,
  "can_attend": true,
  "price": Money.new(25000),
)

Membership.create!(
  "name": "supporting+",
  "active_from": con_announced,
  "active_to": price_change_1,
  "description": nil,
  "can_vote": true,
  "can_nominate": true,
  "can_attend": false,
  "price": Money.new(12500),
)
Membership.create!(
  "name": "unwaged",
  "active_from": con_announced,
  "active_to": nil, # no planned price rise
  "can_vote": true,
  "can_nominate": true,
  "can_attend": true,
  "price": Money.new(22500),
)
Membership.create!(
  "name": "child",
  "active_from": con_announced,
  "active_to": nil, # no planned price rise
  "description": "born in or after 2005",
  "can_vote": false,
  "can_nominate": false,
  "can_attend": true,
  "price": Money.new(10500),
)
Membership.create!(
  "name": "kid_in_tow",
  "active_from": con_announced,
  "active_to": nil, # no planned price rise
  "description": "born in or after 2015",
  "can_vote": false,
  "can_nominate": false,
  "can_attend": true,
  "price": Money.new(0),
)
Membership.create!(
  "name": "supporting",
  "active_from": con_announced,
  "active_to": nil, # no planned price rise
  "description": nil,
  "can_vote": true,
  "can_nominate": true,
  "can_attend": false,
  "price": Money.new(7500),
)
Membership.create!(
  "name": "dublin_2019",
  "description": "Attended Dublin in 2019",
  "active_from": dublin_import,
  "active_to": dublin_import, # not available to the general public
  "can_vote": false,
  "can_nominate": true,
  "can_attend": false, # can nominate, but can't vote
  "price": Money.new(0),
)

hugo = Election.create!(name: "2020 Hugo", i18n_key: "hugo")
hugo.categories.create!(
  name: "Best Novel",
  description: %{
    A science fiction or fantasy story of 40,000 words or more, published for the first time in 2019.
  }.strip_heredoc,
  field_1: "Title",
  field_2: "Author",
  field_3: "Publisher",
)
hugo.categories.create!(
  name: "Best Novella",
  description: %{
    A science fiction or fantasy story between 17,500 and 40,000 words, which appeared for the first time in 2019.
  }.strip_heredoc,
  field_1: "Title",
  field_2: "Author",
  field_3: "Where Published",
)
hugo.categories.create!(
  name: "Best Novelette",
  description: %{
    A science fiction or fantasy story between 7,500 and 17,500 words, which appeared for the first time in 2019.
  }.strip_heredoc,
  field_1: "Title",
  field_2: "Author",
  field_3: "Where Published",
)
hugo.categories.create!(
  name: "Best Short Story",
  description: %{
    A science fiction or fantasy story of fewer than 7,500 words, which appeared for the first time in 2019.
  }.strip_heredoc,
  field_1: "Title",
  field_2: "Author",
  field_3: "Where Published",
)
hugo.categories.create!(
  name: "Best Series",
  description: %{
    A multi-volume science fiction or fantasy story, unified by elements such as plot, characters, setting, and
    presentation, which has appeared in at least three (3) volumes consisting of a total of at least 240,000 words
    by the close of the calendar year 2019, at least one of which was published in 2019, and which has not
    previously won under §3.3.5 of the WSFS Constitution.

    Previous losing finalists in the Best Series category shall be eligible only upon the publication of at least
    two (2) additional installments consisting in total of at least 240,000 words after they qualified for their
    last appearance on the final ballot and by the close of 2019.

    Previous losing finalists in the Best Series category shall be eligible only upon the publication of at least
    two (2) additional installments consisting in total of at least 240,000 words after they qualified for their
    last appearance on the final ballot and by the close of 2019.

    If any series and a subset series thereof both receive sufficient nominations to appear on the final ballot,
    only the version which received more nominations shall appear.

    **Note regarding 2020 Best Series eligibility**

    Previous winners of the Hugo for Best Series under §3.3.5 of the WSFS Constitution are **not** eligible in the
    Best Series category. They are:

    * The World of the Five Gods, by Lois McMaster Bujold
    * Wayfarers, by Becky Chambers

    The following finalists for the Hugo Award for Best Series in 2017 are **not** eligible in 2020 **unless** they have
    published at least two (2) additional installments consisting in total of at least 240,000 words between 1 January
    2017 and 31 December 2019:

    * The Craft Sequence, by Max Gladstone
    * The Expanse, by James S. A. Corey
    * The Peter Grant / Rivers of London series, by Ben Aaronovitch
    * The Temeraire series, by Naomi Novik

    The following finalists for the Hugo Award for Best Series in 2018 are **not** eligible in 2020 **unless** they have
    published at least two (2) additional installments consisting in total of at least 240,000 words between 1 January
    2018 and 31 December 2019:

    * The Books of the Raksura, by Martha Wells
    * The Divine Cities, by Robert Jackson Bennett
    * InCryptid, by Seanan McGuire
    * The Memoirs of Lady Trent, by Marie Brennan
    * The Stormlight Archive, Brandon Sanderson

    The following finalists for the Hugo Award for Best Series in 2019 are **not** eligible in 2020 **unless** they have
    published at least two (2) additional installments consisting in total of at least 240,000 words between 1 January
    2019 and 31 December 2019:

    * The Centenal Cycle, by Malka Older
    * The Laundry Files, by Charles Stross
    * Machineries of Empire, by Yoon Ha Lee
    * The October Daye Series, by Seanan McGuire
    * The Universe of Xuya, by Aliette de Bodard
  }.strip_heredoc,
  field_1: "Series Name",
  field_2: "Author",
  field_3: "2019 Example from Series",
)
hugo.categories.create!(
  name: "Best Related Work",
  description: %{
    Any work related to the field of science fiction, fantasy, or fandom, appearing for the first time in 2019, or
    which has been substantially modified during 2019, and which is either non-fiction or, if fictional, is
    noteworthy primarily for aspects other than the fictional text, and which is not eligible in any other
    category.
  }.strip_heredoc,

  field_1: "Title",
  field_2: "Author/Editor",
  field_3: "Publisher",
)
hugo.categories.create!(
  name: "Best Graphic Story or Comic",
  description: %{
    Any science fiction or fantasy story told in graphic form, appearing for the first time in 2019.
  }.strip_heredoc,
  field_1: "Title",
  field_2: "Author",
  field_3: "Publisher",
)
hugo.categories.create!(
  name: "Best Dramatic Presentation, Long Form",
  description: %{
    Any theatrical feature or other production with a complete running time of more than 90 minutes, in any medium
    of dramatized science fiction, fantasy, or related subjects that has been publicly presented for the first
    time in its present dramatic form during 2019.
  }.strip_heredoc,
  field_1: "Title",
  field_2: "Studio/Network",
  field_3: nil,
)
hugo.categories.create!(
  name: "Best Dramatic Presentation, Short Form",
  description: %{
    Any television program or other production with a complete running time of 90 minutes or less, in any medium
    of dramatized science fiction, fantasy, or related subjects that has been publicly presented for the first
    time in its present dramatic form during 2019.
  }.strip_heredoc,
  field_1: "Title",
  field_2: "(Series)",
  field_3: "Studio/Network",
)
hugo.categories.create!(
  name: "Best Professional Editor, Short Form",
  description: %{
    The editor of at least four (4) anthologies, collections, or magazine issues (or their equivalent in other
    media) primarily devoted to science fiction and/or fantasy, at least one of which was published in 2019.
  }.strip_heredoc,
  field_1: "Editor",
  field_2: nil,
  field_3: nil,
)
hugo.categories.create!(
  name: "Best Professional Editor, Long Form",
  description: %{
    The editor of at least four (4) novel-length works primarily devoted to science fiction and/or fantasy
    published in 2019, which do not qualify under Best Editor, Short Form.
  }.strip_heredoc,
  field_1: "Editor",
  field_2: nil,
  field_3: nil,
)
hugo.categories.create!(
  name: "Best Professional Artist",
  description: %{
    An illustrator whose work has appeared in a professional publication in the field of science fiction or
    fantasy during 2019. A professional publication is one that meets at least one (1) of the following criteria:

     1. It provided at least a quarter of the income of any one person; or
     2. It was owned or published by any entity which provided at least a quarter of the income of any of its
        staff and/or owner. If possible, please cite an example of the nominee’s work. (Failure to provide such
        references will not invalidate a nomination.)
  }.strip_heredoc,

  field_1: "Artist/Illustrator",
  field_2: "Example",
  field_3: nil,
)
hugo.categories.create!(
  name: "Best Semiprozine",
  description: %{
    Any generally available non-professional publication devoted to science fiction or fantasy which by the close
    of 2019 had published at least four (4) issues (or the equivalent in other media), and at least one (1) of
    which appeared in 2019, which does not qualify as a fancast, and which in 2019 has met at least one (1) of the
    following criteria:

    1. Paid its contributors or staff in other than copies of the publication.
    2. Was generally available only for paid purchase.
  }.strip_heredoc,

  field_1: "Title",
  field_2: nil,
  field_3: nil,
)
hugo.categories.create!(
  name: "Best Fanzine",
  description: %{
    Any generally available non-professional publication devoted to science fiction, fantasy, or related subjects which,
    by the close of 2019, had published at least four (4) issues (or the equivalent in other media), at least one (1) of
    which appeared in 2019, and which does not qualify as a semiprozine or a fancast, and which in 2019 met neither of
    the following criteria:

    1. Paid its contributors or staff in other than copies of the publication.
    2. Was generally available only for paid purchase.
  }.strip_heredoc,

  field_1: "Title",
  field_2: nil,
  field_3: nil,
)
hugo.categories.create!(
  name: "Best Fancast",
  description: %{
    Any generally available non-professional audio or video periodical devoted to science fiction, fantasy, or
    related subjects that by the close of 2019 has released four (4) or more episodes, at least one (1) of which
    appeared in 2019, and that does not qualify as a dramatic presentation.
  }.strip_heredoc,

  field_1: "Title",
  field_2: nil,
  field_3: nil,
)
hugo.categories.create!(
  name: "Best Fan Writer",
  description: %{
    A person whose writing has appeared in fanzines or semiprozines, or in generally available electronic media in
    2019.
  }.strip_heredoc,

  field_1: "Author",
  field_2: "Example",
  field_3: nil,
)
hugo.categories.create!(
  name: "Best Fan Artist",
  description: %{
    An artist or cartoonist whose work has appeared through publication in fanzines, semiprozines, or through any
    other public non-professional display (including at a convention or conventions) in 2019.
  }.strip_heredoc,

  field_1: "Artist/Illustrator",
  field_2: "Example",
  field_3: nil,
)
hugo.categories.create!(
  name: "Lodestar Award for Best Young Adult Book (not a Hugo)",
  description: %{
    A book published for young adult readers in the field of science fiction or fantasy appearing for the first time in
    2019.
  }.strip_heredoc,

  field_1: "Title",
  field_2: "Author",
  field_3: "Where Published",
)
hugo.categories.create!(
  name: "Astounding Award for the best new science fiction writer, sponsored by Dell Magazines (not a Hugo)",
  description: %{
    A new writer is one whose first work of science fiction or fantasy appeared in 2018 or 2019 in a professional
    publication. For Astounding Award purposes, a professional publication is one for which more than a nominal amount
    was paid, any publication that had an average press run of at least 10,000 copies, or any other criteria that the
    Award sponsors may designate.
  }.strip_heredoc,

  field_1: "Author",
  field_2: "Example",
  field_3: nil,
)

retro_hugo = Election.create!(name: "1945 Retro Hugo", i18n_key: "retro_hugo")
retro_hugo.categories.create!(
  name: "Retro Best Novel",
  description: %{
    A science fiction or fantasy story of 40,000 words or more, which appeared for the first time in 1944.
  }.strip_heredoc,

  field_1: "Title",
  field_2: "Author",
  field_3: "Publisher",
)
retro_hugo.categories.create!(
  name: "Retro Best Novella",
  description: %{
    A science fiction or fantasy story between 17,500 and 40,000 words, which appeared for the first time in 1944.
  }.strip_heredoc,

  field_1: "Title",
  field_2: "Author",
  field_3: "Where Published",
)
retro_hugo.categories.create!(
  name: "Retro Best Novelette",
  description: %{
    A science fiction or fantasy story between 7,500 and 17,500 words, which appeared for the first time in 1944.
  }.strip_heredoc,

  field_1: "Title",
  field_2: "Author",
  field_3: "Where Published",
)
retro_hugo.categories.create!(
  name: "Retro Best Short Story",
  description: %{
    A science fiction or fantasy story of fewer than 7,500 words, which appeared for the first time in 1944.
  }.strip_heredoc,

  field_1: "Title",
  field_2: "Author",
  field_3: "Where Published",
)
retro_hugo.categories.create!(
  name: "Retro Best Series",
  description: %{
    A multi-volume science fiction or fantasy story, unified by elements such as plot, characters, setting, and
    presentation, which appeared in at least three (3) volumes consisting of a total of at least 240,000 words by
    the close of the calendar year 1944, at least one of which was published in 1944.

    If any series and a subset series thereof both receive sufficient nominations to appear on the final ballot,
    only the version which received more nominations shall appear.
  }.strip_heredoc,

  field_1: "Series Name",
  field_2: "Author",
  field_3: "1944 Example from Series",
)
retro_hugo.categories.create!(
  name: "Retro Best Related Work",
  description: %{
    Any work related to the field of science fiction, fantasy, or fandom, appearing for the first time in 1944, or
    which was substantially modified during 1944, and which is either non-fiction or, if fictional, is noteworthy
    primarily for aspects other than the fictional text, and which is not eligible in any other category.
  }.strip_heredoc,

  field_1: "Series Name",
  field_2: "Author/Editor",
  field_3: "Publisher",
)
retro_hugo.categories.create!(
  name: "Retro Best Graphic Story or Comic",
  description: %{
    Any science fiction or fantasy story told in graphic form, appearing for the first time in 1944.
  }.strip_heredoc,

  field_1: "Title",
  field_2: "Author",
  field_3: "Publisher",
)
retro_hugo.categories.create!(
  name: "Retro Best Dramatic Presentation, Long Form",
  description: %{
    Any theatrical feature or other production with a complete running time of more than 90 minutes, in any medium
    of dramatized science fiction, fantasy, or related subjects that was publicly presented for the first time in
    its present dramatic form during 1944.
  }.strip_heredoc,

  field_1: "Title",
  field_2: "Studio/Network",
  field_3: nil,
)
retro_hugo.categories.create!(
  name: "Retro Best Dramatic Presentation, Short Form",
  description: %{
    Any television program or other production with a complete running time of 90 minutes or less, in any medium
    of dramatized science fiction, fantasy, or related subjects that was publicly presented for the first time in
    its then dramatic form during 1944.
  }.strip_heredoc,

  field_1: "Title",
  field_2: "(Series)",
  field_3: "Studio/Network",
)
retro_hugo.categories.create!(
  name: "Retro Best Professional Editor, Short Form",
  description: %{
    The editor of at least four (4) anthologies, collections, or magazine issues (or their equivalent in other
    media) primarily devoted to science fiction and/or fantasy, at least one of which was published in 1944.
  }.strip_heredoc,

  field_1: "Editor",
  field_2: nil,
  field_3: nil,
)
retro_hugo.categories.create!(
  name: "Retro Best Professional Editor, Long Form",
  description: %{
    The editor of at least four (4) novel-length works primarily devoted to science fiction and/or fantasy
     published in 1944, which did not qualify under Best Editor, Short Form.
  }.strip_heredoc,

  field_1: "Editor",
  field_2: nil,
  field_3: nil,
)
retro_hugo.categories.create!(
  name: "Retro Best Professional Artist",
  description: %{
    An illustrator whose work has appeared in a professional publication in the field of science fiction or
    fantasy during 1944. A professional publication is one that meets at least one (1) of the following criteria:

    1. It provided at least a quarter of the income of any one person; or
    2. It was owned or published by any entity which provided at least a quarter of the income of any of its staff
       and/or owner. If possible, please cite an example of the nominee’s work. (Failure to provide such references
       will not invalidate a nomination.)
  }.strip_heredoc,

  field_1: "Artist/Illustrator",
  field_2: "Example",
  field_3: nil,
)
retro_hugo.categories.create!(
  name: "Retro Best Semiprozine",
  description: %{
    Any generally available non-professional publication devoted to science fiction or fantasy which by the close
    of 1944 had published at least four (4) issues (or the equivalent in other media), and at least one (1) of
    which appeared in 1944, which does not qualify as a fancast, and which in 1944 has met at least one (1) of the
    following criteria:

    1. Paid its contributors or staff in other than copies of the publication.

    2. Was generally available only for paid purchase.
  }.strip_heredoc,

  field_1: "Title",
  field_2: nil,
  field_3: nil,
)
retro_hugo.categories.create!(
  name: "Retro Best Fanzine",
  description: %{
    Any generally available non-professional publication devoted to science fiction, fantasy, or related subjects
    which, by the close of 1944, had published at least four (4) issues (or the equivalent in other media), at
    least one (1) of which appeared in 1944, and which does not qualify as a semiprozine or a fancast, and which
    in 1944 met neither of the following criteria:

    1. Paid its contributors or staff in other than copies of the publication.

    2. Was generally available only for paid purchase.
  }.strip_heredoc,

  field_1: "Title",
  field_2: nil,
  field_3: nil,
)
retro_hugo.categories.create!(
  name: "Retro Best Fancast",
  description: %{
    Any generally available non-professional audio or video periodical devoted to science fiction, fantasy, or
    related subjects that by the close of 1944 had released four (4) or more episodes, at least one (1) of which
    appeared in 1944, and that does not qualify as a dramatic presentation.
  }.strip_heredoc,

  field_1: "Title",
  field_2: nil,
  field_3: nil,
)
retro_hugo.categories.create!(
  name: "Retro Best Fan Writer",
  description: %{
    A person whose writing appeared in fanzines or semiprozines, or in generally available electronic media in
    1944.
  }.strip_heredoc,

  field_1: "Author",
  field_2: "Example",
  field_3: nil,
)
retro_hugo.categories.create!(
  name: "Retro Best Fan Artist",
  description: %{
    An artist or cartoonist whose work appeared through publication in fanzines, semiprozines, or through any
    other public non-professional display (including at a convention or conventions) in 1944.
  }.strip_heredoc,

  field_1: "Artist/Illustrator ",
  field_2: "Example",
  field_3: nil,
)
