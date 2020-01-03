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
require "csv"

RSpec.describe Import::DublinMembers do
  let(:data) { "" }
  let(:read_stream) { StringIO.new(data) }
  let(:description) { "test stream" }

  let!(:dublin_membership) { create(:membership, :dublin_2019) }

  subject(:command) { described_class.new(read_stream, description) }

  describe "#call" do
    subject(:call) { command.call }

    it { is_expected.to be_truthy }

    it "imports nothing when the file is empty" do
      expect { call }.to_not change { Membership.count }
      expect(command.errors).to be_empty
    end

    context "when the headings are wrong" do
      let(:data) do
        CSV.generate do |csv|
          csv << %w(it's the wrong trowsers gromit!)
        end
      end

      it { is_expected.to be_falsey }
    end


    context "when there's data to import" do
      let(:sample_row) do
        {
          eligibility: "dublin",
          dub: "1234",
          nz: "",
          type: "Adult",
          fname: "Firstname goes here",
          lname: "Lastname goes here",
          combined: "Firstlastnamegoeshere",
          email: "enjoy@coke.net",
          city: "Helsinki",
          state: "",
          country: "Finland",
          notes: "notes o glorious notes",
        }
      end

      let(:data) do
        CSV.generate do |csv|
          csv << Import::DublinMembers::HEADINGS
          csv << sample_row.values
        end
      end

      it { is_expected.to be_truthy }

      it "can create users" do
        expect { call }.to change { User.count }.by(1)
      end

      it "doesn't create users if they're already there" do
        create(:user, email: sample_row[:email])
        expect { call }.to_not change { User.count }
      end

      it "creates new Dublin memberships" do
        expect { call }.to change { dublin_membership.reload.orders.count }.by(1)
        expect(Reservation.last).to be_paid
      end

      it "creates details based on passed in data" do
        expect { call }.to change { Detail.count }.by(1)
        expect(Detail.last.country).to eq(sample_row[:country])
        expect(Detail.last.first_name).to eq(sample_row[:fname])
      end

      it "creates notes with line numbers" do
        expect { call }.to change { Note.count }.by_at_least(0)
        expect(Note.last.content).to match(/row 2/i) # note, headings are row 1
        expect(Note.last.content).to include(description)
      end

      context "when that data is labelled 'conzealand'" do
        let(:sample_row) do
          {
            eligibility: "conzealand",
            dub: "1234",
            nz: "",
            type: "Adult",
            fname: "Firstname goes here",
            lname: "Lastname goes here",
            combined: "Firstlastnamegoeshere",
            email: "enjoy@coke.net",
            city: "Helsinki",
            state: "",
            country: "Finland",
            notes: "notes o glorious notes",
          }
        end

        it { is_expected.to be_truthy }

        it "doesn't create users" do
          expect { call }.to_not change { User.count }
        end

        it "doesn't create reservations" do
          expect { call }.to_not change { Reservation.count }
        end
      end
    end
  end
end
