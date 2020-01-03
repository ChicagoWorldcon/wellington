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
  ]

  attr_reader :errors, :csv, :description

  def initialize(io_reader, description)
    @csv = CSV.parse(io_reader)
    @errors = []
    @description = description
  end

  def call
    if !headings.present?
      return true
    end

    if headings != HEADINGS
      errors << "Headings don't match. Got #{headings}, want #{HEADINGS}"
      return false
    end

    # We've wipped off headings already
    # with_index(2) because first data entries start from row 2
    rows.each.with_index(2) do |cells, n|
      row = Hash[HEADINGS.zip(cells)]

      # The unduplicated list includes information about other members so hugohelp@ has context
      # Only import dublin members, skip everyone else
      next if row["eligibility"] != "dublin"

      import_email = row["EMAIL"].downcase.strip
      import_user = User.find_or_create_by!(email: import_email)
      reservation = ClaimMembership.new(dublin_membership, customer: import_user).call
      detail = Detail.new(
        claim: reservation.active_claim,
        first_name: row["FNAME"],
        last_name: row["LNAME"],
        city: row["CITY"],
        province: row["STATE"],
        country: row["COUNTRY"],
        show_in_listings: false,
        share_with_future_worldcons: false,
        publication_format: Detail::PAPERPUBS_ELECTRONIC,
      )
      detail.as_import.save!
      import_user.notes.create!(content: "Dublin membership #{row["DUB#"]}")
      import_user.notes.create!(content: "#{description} row #{n}")
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

  def dublin_membership
    @dublin_membership ||= Membership.find_by!(name: :dublin_2019)
  end
end
