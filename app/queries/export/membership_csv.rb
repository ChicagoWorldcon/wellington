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

require "csv"

class Export::MembershipCsv
  def call
    return if ConzealandContact.none?

    buff = StringIO.new
    csv = CSV.new(buff)

    csv << Export::MembershipRow::HEADINGS
    contacts = ConzealandContact.joins(Export::MembershipRow::JOINS).eager_load(Export::MembershipRow::JOINS)
    contacts.merge(Claim.active).find_each do |contact|
      csv << Export::MembershipRow.new(contact).values
    end

    buff.string
  end
end
