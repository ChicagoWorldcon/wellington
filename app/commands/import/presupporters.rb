# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray, 2018 Andrew Esler
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

# ImportPresupporters takes a stream of text in CSV format and creates member records out of it. Check call return to see if
# it succeeded or not, check errors to see why.
class Import::Presupporters
  attr_reader :input_stream, :description, :fallback_email

  def initialize(input_stream, description:, fallback_email:)
    @input_stream = input_stream
    @description = description
    @fallback_email = fallback_email

    # Check our default user for errors
    if !User.where(email: fallback_email).exists?
      default_user = User.new(email: fallback_email)
      if !default_user.valid?
        raise ArgumentError, "Default user has errors, please fix: #{default_user.errors.full_messages.to_sentence}"
      end
    end
  end

  def call
    check_headings
    return false if errors.any?

    User.transaction do
      table_body.each.with_index do |row_data, i|
        row_import = Import::PresupportersRow.new(row_data,
          comment: "Import from row #{i+2} in #{description}",
          fallback_email: fallback_email
        )
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
    expected = Import::PresupportersRow::HEADINGS
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
