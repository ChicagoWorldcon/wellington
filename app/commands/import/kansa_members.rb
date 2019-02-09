# frozen_string_literal: true

# Copyright 2018 Andrew Esler
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

# ImportKansaMemberss takes a stream of text in CSV format and creates member records out of it. Check call return to see if
# it succeeded or not, check errors to see why.
class Import::KansaMembers
  attr_reader :input_stream, :description

  def initialize(input_stream, description)
    @input_stream = input_stream
    @description = description
  end

  def call
    check_headings
    return false if errors.any?

    User.transaction do
      table_body.each.with_index do |row_data, i|
        row_import = Import::KansaMembersRow.new(row_data, "Import from row #{i+2} in #{description}")
        if !row_import.call
          errors << "Error on row #{i+2}: #{row_import.error_message}"
        end
      end

      if errors.any?
        raise ActiveRecord::Rollback, "Errors encountered while processing CSV"
      end
    end

    errors.none?
  end

  def errors
    @errors ||= []
  end

  private

  def check_headings
    expected = Import::KansaMembersRow::HEADINGS
    if headings != expected
      missing = expected - headings
      excess = headings - expected
      errors << "Headings don't match, missing #{missing.count} and got #{excess.count} surplus to requirements"
    end

    if table_body.empty?
      errors << "table body is empty"
    end

    if table_body.any?(&:empty?)
      errors << "table body has empty rows"
    end
  end

  def headings
    csv.first || []
  end

  def table_body
    csv[1..-1] || []
  end

  def csv
    @csv ||= CSV.parse(input_stream.read) || []
  end
end
