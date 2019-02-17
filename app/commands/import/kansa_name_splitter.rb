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

# Import::KansaNameSplitter takes a name string and provides methods for getting at parts of the name
class Import::KansaNameSplitter
  # Samples selected from https://en.wikipedia.org/wiki/English_honorifics
  TITLES = %w(
    Master
    Baron Viscount
    Mr Mister
    Miss Ms
    Mrs Missus
    Sir Madam
    Sire Dame Lord
    Esq Esquire
    Dr Doctor
    Reverend Father Mother Nun
    Bishop President
  ).freeze

  TITLE_PATTERNS = TITLES.map { |pattern| Regexp.new(pattern, "i") }.freeze

  attr_reader :name

  def initialize(name)
    @name = name.split
  end

  def title
    if TITLE_PATTERNS.any? { |p| p.match(name.first) }
      name.first
    else
      ""
    end
  end

  def first_name
    if name.size <= 1
      []
    elsif title.present?
      name[1..-2]
    else
      name[0..-2]
    end.join(" ")
  end

  def last_name
    name.last || ""
  end
end
