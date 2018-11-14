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

require "rails_helper"

RSpec.describe ImportMembers do
  let!(:adult)       { create(:membership, :adult) }
  let!(:silver_fern) { create(:membership, :silver_fern) }
  let!(:kiwi)        { create(:membership, :kiwi) }

  let(:data) { "" }
  let(:read_stream) { StringIO.new(data) }
  let(:standard_headings) { ImportMembers::HEADINGS.join(",") }
  let(:description) { "test stream" }
  subject(:command) { ImportMembers.new(read_stream, description) }

  it "imports nothing when the file is empty" do
    expect { command.call }.to_not change { Membership.count }
  end

  it "fails without the right headings" do
    expect(command.call).to be false
    expect(command.errors).to include(/headings/i)
  end

  context "when just the headings" do
    let(:data) { "#{standard_headings}\n\n\n" }

    it "fails complaining about the body" do
      expect(command.call).to be false
      expect(command.errors).to include(/empty rows/i)
    end
  end

  context "with import data" do
    let(:data) do
      CSV.generate do |csv|
        csv << ImportMembers::HEADINGS
        csv << member_row
      end
    end
    let(:email_address) { "test@matthew.nz" }

    let(:member_row) do
      [
        "09/02/2010 21:39:00",
        "Skux",
        "Pizazz",
        "",
        "",
        "",
        "",
        "4001 Summerhill Drive #5-76",
        "",
        "Palmerston North",
        "Manawatu",
        "4410",
        "New Zealand",
        email_address,
        kiwi.name,
        "NULL",
        "",
        "",
        "",
        "",
        "",
        "FALSE",
        "FALSE",
        "",
        "",
        "",
        "",
        "FALSE",
        "FALSE",
        "FALSE",
        "FALSE",
        "FALSE",
        "FALSE",
        "FALSE",
        "",
        "100003",
        "",
        "",
        "HackermanNZA",
        "Hackerman Matt",
        "",
        "",
        "",
        "",
        "",
        "FALSE",
        "NO",
        "Kiwi",
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
        expect { command.call }.to change { kiwi.reload.active_orders.count }.by(1)
        expect(User.last.purchases).to eq(kiwi.purchases)
      end

      context "after run" do
        before do
          command.call
        end

        it "creates a cash charge" do
          expect(User.last.charges.successful.cash.count).to be(1)
        end

        it "describes the source of the import" do
          expect(Charge.last.comment).to match(/row 2/i)
        end

        it "sets membership to paid" do
          expect(Purchase.last.state).to eq Purchase::PAID
        end
      end
    end
  end
end
