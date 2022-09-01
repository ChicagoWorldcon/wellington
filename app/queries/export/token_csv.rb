# frozen_string_literal: true

# Copyright 2022 Chris Rose
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

class Export::TokenCsv
  def call
    return if ChicagoContact.none?

    buff = StringIO.new
    csv = CSV.new(buff)

    csv << Export::TokenRow::HEADINGS
    contacts = ChicagoContact.joins(Export::TokenRow::JOINS).eager_load(Export::TokenRow::JOINS)
    contacts.merge(Claim.active).find_each do |contact|
      csv << Export::TokenRow.new(contact).values
    end

    buff.string
  end
end
