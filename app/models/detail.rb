# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
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
  PAPERPUBS_ELECTRONIC = "electronic_only"
  PAPERPUBS_MAIL = "mail_only"
  PAPERPUBS_BOTH = "both"
  PAPERPUBS_NONE = "none"

  belongs_to :claim

  validates :address_line_1, presence: true
  validates :claim, presence: true
  validates :country, presence: true
  validates :full_name, presence: true
  validates :publication_format, inclusion: { in: [PAPERPUBS_ELECTRONIC, PAPERPUBS_MAIL, PAPERPUBS_BOTH, PAPERPUBS_NONE] }
end
