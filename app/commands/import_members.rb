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

require "csv"

# ImportMembers takes a stream of text in CSV format and creates member records out of it. Check call return to see if
# it succeeded or not, check errors to see why.
class ImportMembers
  HEADINGS = [
    "Timestamp",
    "Given Name",
    "Family Name",
    "Display Given Name",
    "Display Family Name",
    "Display / Badge Name",
    "Badge Subtitle",
    "Address 1",
    "Address 2",
    "City",
    "Province/State",
    "Postal/Zip Code",
    "Country",
    "Email",
    "Pre-Support Membership Status",
    "GDPR Opt IN",
    "Phone",
    "SJ MemberID",
    "Entered New From Site Selection",
    "Listings",
    "Share With Future Worldcons",
    "No electronic publications",
    "Paper Publications",
    "Con Membership Status From Forms",
    "Payment",
    "Type",
    "Currency",
    "TRUE",
    "Accessibility Services",
    "Being on Program",
    "Dealers",
    "Selling at Art Show",
    "Exhibiting",
    "Performing",
    "Notes",
    "Faked Primary Key",
    "NameAndCountry",
    "CombinedName",
    "Voted In Site Selection",
    "GDPR on Email",
    "MatchOnName",
    "GDPR on Name",
    "Voted in Site Selection",
    "Full Member based on data import",
    "Member combined data and form information",
  ]

  attr_reader :input_stream

  def initialize(input_stream)
    @input_stream = input_stream
  end

  def call
    check_headings
    errors.none?
  end

  def errors
    @errors ||= []
  end

  private

  def check_headings
    if headings != HEADINGS
      missing = HEADINGS - headings
      excess = headings - HEADINGS
      errors << "Headings don't match, missing #{missing.count} and got #{excess.count} surplus to requirements"
    end

    if table_body.empty?
      errors << "Table body is empty"
    end
  end

  def headings
    csv.first || []
  end

  def table_body
    csv[1..-1] || []
  end

  def csv
    CSV.parse(input_stream.read) || []
  end
end
