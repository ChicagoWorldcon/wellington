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
        csv << row_1
        csv << row_2
      end
    end
    let(:email_address) { "test@matthew.nz" }
    let(:good_row_processor) { instance_double(ImportMembers::ProcessRow, call: true) }
    let(:bad_row_processor) { instance_double(ImportMembers::ProcessRow, call: false, error_message: "gah") }

    let(:row_1) { ["1"] * ImportMembers::HEADINGS.count }
    let(:row_2) { ["2"] * ImportMembers::HEADINGS.count }

    it "calls ProcessRow" do
      expect(ImportMembers::ProcessRow)
        .to receive(:new).with(row_1, "Import from row 2 in #{description}")
        .and_return(good_row_processor)
      expect(ImportMembers::ProcessRow)
        .to receive(:new).with(row_2, "Import from row 3 in #{description}")
        .and_return(good_row_processor)
      expect(command.call).to be_truthy
      expect(command.errors).to be_empty
    end

    it "raises errors with buggy rows" do
      expect(ImportMembers::ProcessRow)
        .to receive(:new).with(row_1, "Import from row 2 in #{description}")
        .and_return(good_row_processor)
      expect(ImportMembers::ProcessRow)
        .to receive(:new).with(row_2, "Import from row 3 in #{description}")
        .and_return(bad_row_processor)
      expect(command.call).to be_falsey
      expect(command.errors).to include(/gah/i)
    end
  end
end
