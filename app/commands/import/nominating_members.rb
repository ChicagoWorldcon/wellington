# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2021 Fred Bauer
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

# Import::NominateMembers takes a CSV provided by the previous year's convention, from which current members have been removed.  It is 
# used to allow the last year's members to nominate for the Hugos.  Note that manual de-duplication is required, to make that an individual
# is not allowed two nominating votes.  Some members use unique email addresses for each convention, so an automated comparison is difficult. 
# Future updates could help with this process.

class Import::NominateMembers
  HEADINGS = [
    "PREVIOUS#",
    "Class Type",
    "FNAME",
    "LNAME",
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
      # next if row["eligibility"] != "dublin"

      import_email = row["EMAIL"].downcase.strip
      import_user = User.find_or_create_by!(email: import_email)
      reservation = ClaimMembership.new(nominating_membership, customer: import_user).call
      contact = ConzealandContact.new(
        claim: reservation.active_claim,
        first_name: row["FNAME"],
        last_name: row["LNAME"],
        city: row["CITY"],
        province: row["STATE"],
        country: row["COUNTRY"],
        show_in_listings: false,
        share_with_future_worldcons: false,
        publication_format: DCContact::PAPERPUBS_ELECTRONIC,
      )
      contact.as_import.save!
      import_user.notes.create!(content: "Nominating membership #{row["PREVIOUS#"]}")
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

  def nominating_membership
    @nominating_membership ||= Membership.find_by!(name: :nominating)
  end
end
