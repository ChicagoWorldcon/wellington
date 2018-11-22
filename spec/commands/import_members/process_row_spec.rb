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

RSpec.describe ImportMembers::ProcessRow do
  let!(:adult)       { create(:membership, :adult) }
  let!(:silver_fern) { create(:membership, :silver_fern) }
  let!(:kiwi)        { create(:membership, :kiwi) }

  let(:email_address) { Faker::Internet.email }
  let(:my_comment) { "suite comment" }

  subject(:command) { ImportMembers::ProcessRow.new(row_values, my_comment) }

  let(:row_values) do
    [
      "8/19/2018 10:04:55",             # Timestamp
      "",                               # Title
      "",                               # Title
      "",                               # Title
      Faker::FunnyName.three_word_name, # Full name
      Faker::Name.first_name,           # PreferredFirstname
      Faker::Name.last_name,            # PreferedLastname
      Faker::Superhero.name,            # BadgeTitle
      Faker::Superhero.descriptor,      # BadgeSubtitle
      Faker::Address.street_address,    # Address Line1
      Faker::Address.secondary_address, # Address Line2
      Faker::Address.city,              # City
      Faker::Address.state,             # Province/State
      Faker::Address.zip_code,          # Postal/Zip Code
      Faker::Address.country,           # Country
      email_address,                    # Email Address
      "Given and Last",                 # Listings
      "",                               # Use Real Name
      "",                               # Use Badge
      "",                               # Share detalis?
      "Yes",                            # Share With Future Worldcons
      "FALSE",                          # No electronic publications
      "TRUE",                           # Paper Publications
      "FALSE",                          # Volunteering
      "TRUE",                           # Accessibility Services
      "FALSE",                          # Being on Program
      "FALSE",                          # Dealers
      "TRUE",                           # Selling at Art Show
      "FALSE",                          # Exhibiting
      "TRUE",                           # Performing
      "Enjoys long walks by the sea",   # Notes
      "1324",                           # Import Key
      "Silver Fern Pre-Support",        # Pre-Support Status
      "Silver Fern Pre-Support",        # Membership Status
      "",                               # Master Membership Status
    ]
  end

  context "with one member" do
    it "executes successfully" do
      expect(command.call).to be_truthy
      expect(command.errors).to be_empty
    end

    it "imports a member" do
      expect { command.call }.to change { User.count }.by(1)
      expect(User.last.email).to eq email_address
    end

    it "puts a new active order against that membership" do
      expect { command.call }.to change { silver_fern.reload.active_orders.count }.by(1)
      expect(User.last.purchases).to eq(silver_fern.purchases)
    end

    context "after run" do
      before do
        command.call
      end

      it "creates a cash charge" do
        expect(User.last.charges.successful.cash.count).to be(1)
      end

      it "describes the source of the import" do
        expect(Charge.last.comment).to match(my_comment)
      end

      it "sets membership to paid" do
        expect(Purchase.last.state).to eq Purchase::PAID
      end
    end
  end
end
