# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
# Copyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");

hugo = Election.create!(name: "2021 Hugo", i18n_key: "hugo")
hugo.categories.create!(
  name: "Best Novel",
  description: %{
    A science fiction or fantasy story of 40,000 words or more, published for the first time in 2020.
  }.strip_heredoc,
  field_1: "Title",
  field_2: "Author",
  field_3: "Publisher",
)
hugo.categories.create!(
  name: "Best Novella",
  description: %{
    A science fiction or fantasy story between 17,500 and 40,000 words, which appeared for the first time in 2020.
  }.strip_heredoc,
  field_1: "Title",
  field_2: "Author",
  field_3: "Where Published",
)
hugo.categories.create!(
  name: "Best Novelette",
  description: %{
    A science fiction or fantasy story between 7,500 and 17,500 words, which appeared for the first time in 2020.
  }.strip_heredoc,
  field_1: "Title",
  field_2: "Author",
  field_3: "Where Published",
)
hugo.categories.create!(
  name: "Best Short Story",
  description: %{
    A science fiction or fantasy story of fewer than 7,500 words, which appeared for the first time in 2020.
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
    by the close of the calendar year 2020, at least one of which was published in 2020, and which has not
    previously won under §3.3.5 of the WSFS Constitution.

    Previous losing finalists in the Best Series category shall be eligible only upon the publication of at least
    two (2) additional installments consisting in total of at least 240,000 words after they qualified for their
    last appearance on the final ballot and by the close of 2020.

    If any series and a subset series thereof both receive sufficient nominations to appear on the final ballot,
    only the version which received more nominations shall appear.

    **Note regarding 2021 Best Series eligibility**

    Previous winners of the Hugo for Best Series are **not** eligible in the Best Series category. They are:

    * The Vorkosigan Saga, by Lois McMaster Bujold
    * The World of the Five Gods, by Lois McMaster Bujold
    * Wayfarers, by Becky Chambers

    The following finalists for the Hugo Award for Best Series in 2017 are **not** eligible in 2021 **unless** they have
    published at least two (2) additional installments consisting in total of at least 240,000 words between 1 January
    2019 and 31 December 2020:

    * The Craft Sequence, by Max Gladstone
    * The Expanse, by James S. A. Corey
    * The Peter Grant / Rivers of London series, by Ben Aaronovitch
    * The Temeraire series, by Naomi Novik

    The following finalists for the Hugo Award for Best Series in 2020 are **not** eligible in 2021 **unless** they have
    published at least two (2) additional installments consisting in total of at least 240,000 words between 1 January
    2020 and 31 December 2020:

    * The Books of the Raksura, by Martha Wells
    * The Divine Cities, by Robert Jackson Bennett
    * InCryptid, by Seanan McGuire
    * The Memoirs of Lady Trent, by Marie Brennan
    * The Stormlight Archive, Brandon Sanderson

    The following finalists for the Hugo Award for Best Series in 2021 are **not** eligible in 2021 **unless** they have
    published at least two (2) additional installments consisting in total of at least 240,000 words between 1 January
    2020 and 31 December 2020:

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
    which has been substantially modified during 2020, and which is either non-fiction or, if fictional, is
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
    Any science fiction or fantasy story told in graphic form, appearing for the first time in 2020.
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
    time in its present dramatic form during 2020.
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
    time in its present dramatic form during 2020.
  }.strip_heredoc,
  field_1: "Title",
  field_2: "(Series)",
  field_3: "Studio/Network",
)
hugo.categories.create!(
  name: "Best Editor, Short Form",
  description: %{
    The editor of at least four (4) anthologies, collections, or magazine issues (or their equivalent in other
    media) primarily devoted to science fiction and/or fantasy, at least one of which was published in 2020.
  }.strip_heredoc,
  field_1: "Editor",
  field_2: nil,
  field_3: nil,
)
hugo.categories.create!(
  name: "Best Editor, Long Form",
  description: %{
    The editor of at least four (4) novel-length works primarily devoted to science fiction and/or fantasy
    published in 2020, which do not qualify under Best Editor, Short Form.
  }.strip_heredoc,
  field_1: "Editor",
  field_2: nil,
  field_3: nil,
)
hugo.categories.create!(
  name: "Best Professional Artist",
  description: %{
    An illustrator whose work has appeared in a professional publication in the field of science fiction or
    fantasy during 2020. A professional publication is one that meets at least one (1) of the following criteria:

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
    which appeared in 2020, which does not qualify as a fancast, and which in 2019 has met at least one (1) of the
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
    which appeared in 2020, and which does not qualify as a semiprozine or a fancast, and which in 2019 met neither of
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
    appeared in 2020, and that does not qualify as a dramatic presentation.
  }.strip_heredoc,

  field_1: "Title",
  field_2: nil,
  field_3: nil,
)
hugo.categories.create!(
  name: "Best Fan Writer",
  description: %{
    A person whose writing has appeared in fanzines or semiprozines, or in generally available electronic media in
    2020.
  }.strip_heredoc,

  field_1: "Author",
  field_2: "Example",
  field_3: nil,
)
hugo.categories.create!(
  name: "Best Fan Artist",
  description: %{
    An artist or cartoonist whose work has appeared through publication in fanzines, semiprozines, or through any
    other public non-professional display (including at a convention or conventions) in 2020.
  }.strip_heredoc,

  field_1: "Artist/Illustrator",
  field_2: "Example",
  field_3: nil,
)
hugo.categories.create!(
  name: "Best Video Game",
  description: %{
    An eligible work for the 2021 special Hugo award is any game or substantial
    modification of a game first released to the public on a major gaming platform in 2020,
    in the fields of science fiction, fantasy, or related subjects.

    For these purposes, a game is defined as a work wherein player choice, interaction, or
    participation significantly impacts the narrative, play, meaning, or experience. A major
    gaming platform means that the game is available on personal computers such as
    Windows, Mac, or Linux computers (including, but not limited to, via Steam, Epic, itch.io,
    browser, or direct download), iOS, Android, Switch, PlayStation, and/or Xbox systems.
  }.strip_heredoc,

  field_1: "Artist/Illustrator",
  field_2: "Example",
  field_3: nil,
)
hugo.categories.create!(
  name: "Lodestar Award for Best Young Adult Book (not a Hugo)",
  description: %{
    A book published for young adult readers in the field of science fiction or fantasy appearing for the first time in
    2020.
  }.strip_heredoc,

  field_1: "Title",
  field_2: "Author",
  field_3: "Where Published",
)
hugo.categories.create!(
  name: "Astounding Award for the best new science fiction writer, sponsored by Dell Magazines (not a Hugo)",
  description: %{
    A new writer is one whose first work of science fiction or fantasy appeared in 2019 or 2020 in a professional
    publication. For Astounding Award purposes, a professional publication is one for which more than a nominal amount
    was paid, any publication that had an average press run of at least 10,000 copies, or any other criteria that the
    Award sponsors may designate.
  }.strip_heredoc,

  field_1: "Author",
  field_2: "Example",
  field_3: nil,
)

