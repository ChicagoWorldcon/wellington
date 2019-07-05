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
  factory :category do
    name { "Best Novel" }
    description { "Awarded for a science fiction or fantasy story of forty thousand (40,000) words or more." }

    trait :best_novel do
      name { "Best Novel" }
      description { "Awarded for a science fiction or fantasy story of forty thousand (40,000) words or more." }
    end

    trait :best_novella do
      name { "Best Novella" }
      description {
        %{
          Awarded for a science fiction or fantasy story of between seventeen thousand five hundred (17,500) and forty
          thousand (40,000) words.
        }
      }
    end

    trait :best_novelette do
      name { "Best Novelette" }
      description {
        %{
          Awarded for a science fiction or fantasy story of between seven thousand five hundred (7,500) and seventeen
          thousand five hundred (17,500) words."
        }
      }
    end

    trait :best_short_story do
      name { "Best Short Story" }
      description {
        %{
          Awarded for science fiction or fantasy story of less than seven thousand five hundred (7,500) words.
        }
      }
    end

    trait :best_related_work do
      name { "Best Related Work" }
      description {
        %{
          Awarded to a work related to the field of science fiction, fantasy, or fandom, appearing for the first time
          during the previous calendar year or which has been substantially modified during the previous calendar year.
          The type of works eligible include, but are not limited to, collections of art, works of literary criticism,
          books about the making of a film or TV series, biographies and so on, provided that they do not qualify for
          another category. Specifically, the Constitution says that any work in this category must be “either
          non-fiction or, if fictional, is noteworthy primarily for aspects other than the fictional text, and which is
          not eligible in any other category.” Nonfiction collections are eligible here, but fiction anthologies
          generally are not because all of the individual works within the anthology are eligible in one of the “story”
          categories. There is no category for “Best Anthology.”
        }
      }
    end

    trait :best_graphic_story do
      name { "Best Graphic Story" }
      description {
        %{
          A science fiction or fantasy story told in graphic form, such as a comic book, graphic novel, or webcomic.
        }
      }
    end

    trait :best_dramatic_presentation_long_form do
      name { "Best Dramatic Presentation (Long Form)" }
      description {
        %{
          This Award can be given a dramatized production in any medium, including film, television, radio, live
          theater, computer games or music. The work must last 90 minutes or longer (excluding commercials).
        }
      }
    end

    trait :best_dramatic_presentation_short_form do
      name { "Best Dramatic Presentation (Short Form)" }
      description {
        %{
          This Award can be given a dramatized production in any medium, including film, television, radio, live
          theater, computer games or music. The work must be less than 90 minutes long (excluding commercials).
        }
      }
    end

    trait :best_editor_long_form do
      name { "Best Editor (Long Form)" }
      description {
        %{
          This is the first of the person categories, so the Award is given for the work that person has done in the
          year of eligibility. To be eligible the person must have edited at least 4 novel-length (i.e. 40,000 words or
          more) books devoted to science fiction and/or fantasy in the year of eligibility that are not anthologies or
          collections.
        }
      }
    end

    trait :best_editor_short_form do
      name { "Best Editor (Short Form)" }
      description {
        %{
          To be eligible the person must have edited at least four anthologies, collections or magazine issues devoted
          to science fiction and/or fantasy, at least one of which must have been published in the year of eligibility.
        }
      }
    end

    trait :best_professional_artist do
      name { "Best Professional Artist" }
      description {
        %{
          Another person category, this time for artists and illustrators. The work on which the nominees are judged
          must class as “professional” (see above for a discussion of how “professional” is defined).
        }
      }
    end

    trait :best_semiprozine do
      name { "Best Semiprozine" }
      description {
        %{
          This is the first of the three serial publication/work categories. To qualify, the publication must have
          produced at least 4 issues, at least one of which must have appeared in the year of eligibility (this being
          similar to the requirements for magazine editors in Best Editor, Short Form), and meet additional requirements
          as listed below.
        }
      }
    end

    trait :john_w_campbell_award do
      name { "The John W. Campbell Award" }
      description {
        %{
          The John W. Campbell Award for Best New Writer is not a Hugo. It is voted for and presented alongside the
          Hugos, but the eligibility rules are not governed by the WSFS Constitution. For further details of the
          Campbell see its own web site.
        }
      }
    end
  end
end
