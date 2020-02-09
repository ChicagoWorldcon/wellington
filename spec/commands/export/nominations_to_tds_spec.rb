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

require "rails_helper"

RSpec.describe Export::NominationsToTds do
  subject(:command) { described_class.new }

  describe "#call" do
    subject(:call) { command.call }

    let!(:reservation) { create(:reservation, :with_claim_from_user) }
    let!(:hugo_2020) { create(:election) }
    let!(:hugo_1945) { create(:election, :retro) }
    let!(:category_2020) { create(:category, election: hugo_2020) }
    let!(:category_1945) { create(:category, election: hugo_1945) }

    it "doesn't execute queries when there no nominations" do
      expect(TinyTds::Client).to_not receive(:new)
      call
    end

    context "when there are nominations for 2020" do
      let!(:nomination) { create(:nomination, reservation: reservation, category: category_2020) }

      let(:tiny_tds_result) { instance_double(TinyTds::Result, insert: :mock_insert_result) }
      let(:tiny_tds_client) { instance_double(TinyTds::Client, escape: nomination.field_1) }
      before { expect(TinyTds::Client).to receive(:new).and_return(tiny_tds_client) }

      it "replaces entries in the database" do
        expect(tiny_tds_client).to receive(:execute).once.with(/DELETE.*2020/i).and_return(tiny_tds_result)
        expect(tiny_tds_client).to receive(:execute).once.with(/INSERT.*2020/i).and_return(tiny_tds_result)
        expect(tiny_tds_client).to receive(:execute).once.with(/DELETE.*1945/i).and_return(tiny_tds_result)
        call
      end
    end

    context "when there are nominations for 1945" do
      let!(:nomination) { create(:nomination, reservation: reservation, category: category_1945) }

      let(:tiny_tds_result) { instance_double(TinyTds::Result, insert: :mock_insert_result) }
      let(:tiny_tds_client) { instance_double(TinyTds::Client, escape: nomination.field_1) }
      before { expect(TinyTds::Client).to receive(:new).and_return(tiny_tds_client) }

      it "replaces entries in the database" do
        expect(tiny_tds_client).to receive(:execute).once.with(/DELETE.*2020/i).and_return(tiny_tds_result)
        expect(tiny_tds_client).to receive(:execute).once.with(/DELETE.*1945/i).and_return(tiny_tds_result)
        expect(tiny_tds_client).to receive(:execute).once.with(/INSERT.*1945/i).and_return(tiny_tds_result)
        call
      end
    end
  end
end
