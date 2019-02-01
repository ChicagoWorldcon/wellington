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

class Detail < ApplicationRecord
  # TODO Move this to i18n
  PAPERPUBS_ELECTRONIC = "send_me_email"
  PAPERPUBS_MAIL = "send_me_post"
  PAPERPUBS_BOTH = "send_me_email_and_post"
  PAPERPUBS_NONE = "no_paper_pubs"

  PAPERPUBS_OPTIONS = [
    PAPERPUBS_ELECTRONIC,
    PAPERPUBS_MAIL,
    PAPERPUBS_BOTH,
    PAPERPUBS_NONE
  ].freeze

  belongs_to :claim

  attr_reader :for_import

  validates :address_line_1, presence: true, unless: :for_import
  validates :claim, presence: true
  validates :country, presence: true, unless: :for_import
  validates :full_name, presence: true
  validates :publication_format, inclusion: { in: PAPERPUBS_OPTIONS }

  def as_import
    @for_import = true
    self
  end
end
