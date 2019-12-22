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

require "csv"

class Import::DublinMembers
  HEADINGS = [
    "eligibility",
    "DUB#",
    "NZ#",
    "Class Type",
    "FNAME",
    "LNAME",
    "combined",
    "EMAIL",
    "CITY",
    "STATE",
    "COUNTRY",
    "notes"
  ]

  attr_reader :errors, :csv

  def initialize(io_reader, description)
    @csv = CSV.new(io_reader)
    @errors = []
  end

  def call
    if !headings.present?
      return true
    end

    if headings != HEADINGS
      errors << "Headings don't match. Got #{headings}, want #{HEADINGS}"
      return false
    end

    true
  end

  private

  def headings
    @headings ||= csv.first
  end

  def rows
    @rows ||= csv[1..-1]
  end
end
