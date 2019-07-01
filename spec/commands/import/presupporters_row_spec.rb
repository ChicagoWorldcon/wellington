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

require "rails_helper"

RSpec.describe Import::PresupportersRow do
  let!(:adult)       { create(:membership, :adult) }
  let!(:silver_fern) { create(:membership, :silver_fern) }
  let!(:kiwi)        { create(:membership, :kiwi) }
  let!(:supporter)   { create(:membership, :supporting) }
  let!(:pre_support) { create(:membership, :pre_support) }

  let(:email_address) { Faker::Internet.email }
  let(:my_comment) { "suite comment" }
  let(:fallback_email) { "fallback@conzealand.nz" }

  subject(:command) { Import::PresupportersRow.new(row_values, comment: my_comment, fallback_email: fallback_email) }

  let(:import_key) { "brilliant-import-key" }
  let(:spreadsheet_notes) { "Enjoys long walks by the sea" }
  let(:paper_pubs) { "TRUE" }
  let(:no_electonic_publications) { "FALSE" }
  let(:timestamp) { "2017-10-11" }
  let(:kiwi_site_selection) { "" }
  let(:membership_status) { "Supporting" }

  let(:row_values) do
    [
      timestamp,                        # Timestamp
      Faker::Superhero.prefix,          # Title
      Faker::Superhero.name,            # Given Name
      Faker::Superhero.descriptor,      # Family Name
      Faker::Name.first_name,           # Display Given Name
      Faker::Name.last_name,            # Display Family Name
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
      no_electonic_publications,        # No electronic publications
      paper_pubs,                       # Paper Publications
      "FALSE",                          # Volunteering
      "TRUE",                           # Accessibility Services
      "FALSE",                          # Being on Program
      "FALSE",                          # Dealers
      "TRUE",                           # Selling at Art Show
      "FALSE",                          # Exhibiting
      "TRUE",                           # Performing
      spreadsheet_notes,                # Notes
      import_key,                       # Import Key
      "Kiwi Pre-Support",               # Pre-Support Status
      membership_status,                # Membership Status
      kiwi_site_selection,              # Kiwi Pre-Support and Voted in Site Selection
    ]
  end

  context "when two rows have the same email adderss" do
    before do
      expect(Import::PresupportersRow.new(row_values, comment: my_comment, fallback_email: fallback_email).call).to be_truthy
      expect(Import::PresupportersRow.new(row_values, comment: my_comment, fallback_email: fallback_email).call).to be_truthy
    end

    it "only creates the one user" do
      expect(User.count).to be(1)
    end

    it "creates two sets of detail rows" do
      expect(Detail.count).to be(2)
    end
  end

  context "with one member" do
    let(:imported_user) { User.last }
    let(:imported_reservation) { Reservation.last }

    it "executes successfully" do
      expect(command.call).to be_truthy
      expect(command.errors).to be_empty
    end

    it "imports a member" do
      expect { command.call }.to change { User.count }.by(1)
      expect(imported_user.email).to eq email_address
    end

    it "puts a new active order against that membership" do
      expect { command.call }.to change { supporter.reload.active_orders.count }.by(1)
      expect(imported_user.reservations).to eq(supporter.reservations)
    end

    it "creates detail record from row" do
      expect { command.call }.to change { Detail.count }.by(1)
      expect(Detail.last.import_key).to eq import_key
    end

    context "with presupport worth $0" do
      let(:membership_status) { "Pre-Supporting" }

      it "doesn't create charges" do
        expect(pre_support.price).to be_zero
        expect { command.call }.to_not change { Charge.count }
      end
    end

    context "after run" do
      let(:successful_cash_charges) { imported_user.charges.successful.cash }

      before do
        expect(command.call).to be_truthy
      end

      it "creates a cash charge" do
        expect(successful_cash_charges.count).to be(1)
      end

      it "charge covers value of membership" do
        covered = successful_cash_charges.sum(&:amount)
        expect(covered).to eq supporter.price
      end

      it "sets membership to paid" do
        expect(imported_reservation.state).to eq Reservation::PAID
      end

      context "when voted in site selection" do
        let(:account_credit) { Money.new(50_00) }
        let(:kiwi_site_selection) { "TRUE" }

        it "grants more credit to the account" do
          expect(successful_cash_charges.sum(&:amount)).to eq(supporter.price + account_credit)
        end

        it "sets membership to paid" do
          expect(imported_reservation.state).to eq Reservation::PAID
        end

        # Light integration check, sorry if this test knows a lot
        it "lets you upgrade to adult" do
          upgrader = UpgradeMembership.new(imported_reservation, to: adult)
          expect(upgrader.call).to be_truthy
          imported_reservation.reload
          expect(imported_reservation.membership).to eq(adult)
          expect(imported_reservation).to be_installment
          expect(successful_cash_charges.sum(:amount_cents)).to be > supporter.price_cents
          expect(successful_cash_charges.sum(:amount_cents)).to be < adult.price_cents
        end
      end

      it "describes the source of the import" do
        expect(Charge.last.comment).to match(my_comment)
      end

      it "links through from the user's claim" do
        expect(Claim.last.detail.import_key).to eq Detail.last.import_key
      end

      it "stores notes on that record" do
        expect(Note.last.content).to eq spreadsheet_notes
      end

      describe "#preferred_publication_format" do
        subject { Detail.last.publication_format }

        context "when electronic and mail" do
          let(:paper_pubs) { "TRUE" }
          let(:no_electonic_publications) { "FALSE" }
          it { is_expected.to eq(Detail::PAPERPUBS_BOTH) }
        end

        context "when mail only" do
          let(:paper_pubs) { "TRUE" }
          let(:no_electonic_publications) { "TRUE" }
          it { is_expected.to eq(Detail::PAPERPUBS_MAIL) }
        end

        context "when electronic only" do
          let(:paper_pubs) { "FALSE" }
          let(:no_electonic_publications) { "FALSE" }
          it { is_expected.to eq(Detail::PAPERPUBS_ELECTRONIC) }
        end

        context "when opting out of paper pubs" do
          let(:paper_pubs) { "FALSE" }
          let(:no_electonic_publications) { "TRUE" }
          it { is_expected.to eq(Detail::PAPERPUBS_NONE) }
        end
      end

      it "set created_at on reservation dates based on spreadsheet" do
        expect(Detail.last.created_at).to be < 1.week.ago
        expect(Order.last.created_at).to be < 1.week.ago
        expect(Charge.last.created_at).to be < 1.week.ago
        expect(Claim.last.created_at).to be < 1.week.ago
        expect(imported_reservation.created_at).to be < 1.week.ago
        expect(imported_reservation.created_at).to eq(imported_reservation.updated_at)
      end

      it "sets the active_from fields based on spreadsheet" do
        expect(Claim.last.active_from).to be < 1.week.ago
        expect(Order.last.active_from).to be < 1.week.ago
      end

      it "doesn't set user created_at based on spreadsheet" do
        expect(imported_user.created_at).to be > 1.minute.ago
      end

      context "when created_at is not set" do
        let(:timestamp) { "" }

        it "just uses the current date" do
          expect(imported_reservation.created_at).to be > 1.minute.ago
        end
      end
    end
  end
end
