# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
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

# SiteSelection represents a membership reservation voting on the site for the next Worldcon
class SiteSelection < ApplicationRecord
  VALID_TOKEN = /
    \A
      \d\d\d\d - \d\d\d\d - \d\d\d\d
    \z
  /x.freeze

  def self.generate_token
    token = Luhn.generate(12)
    groupings = token.chars.in_groups_of(4)
    groupings.map(&:join).join("-")
  end

  belongs_to :reservation

  validate :token_checksum
  validates :token, uniqueness: true

  private

  def token_checksum
    if !token.present? || !token.match(VALID_TOKEN)
      errors[:token] << "should match 0000-0000-0000"
      return
    end

    errors[:token] << "checksum failed" unless Luhn.valid?(token)
  end
end
