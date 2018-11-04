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

RSpec.describe UpgradesAvailable do
  let(:query) { UpgradesAvailable.new(from: from) }

  let!(:adult)       { create(:membership, :adult) }
  let!(:young_adult) { create(:membership, :young_adult) }
  let!(:unwaged)     { create(:membership, :unwaged) }
  let!(:child)       { create(:membership, :child) }
  let!(:kid_in_tow)  { create(:membership, :kid_in_tow) }
  let!(:supporting)  { create(:membership, :supporting) }
  let!(:silver_fern) { create(:membership, :silver_fern) }
  let!(:kiwi)        { create(:membership, :kiwi) }

  describe "#keys" do
    let(:result) { query.call }
    subject(:upgrade_options) {
      result.map(&:to_membership)
    }

    context "when adult" do
      let(:from) { "adult" }
      it { is_expected.to be_empty }
    end

    context "when unwaged" do
      let(:from) { "unwaged" }
      it { is_expected.to include adult }
      it { is_expected.to_not include young_adult }
      it { is_expected.to_not include child }
    end

    context "when young adult" do
      let(:from) { "young_adult" }
      it { is_expected.to include adult }
      it { is_expected.to_not include unwaged }
      it { is_expected.to_not include kid_in_tow }
    end

    context "when kid_in_tow" do
      let(:from) { "supporting" }
      it { is_expected.to include adult }
      it { is_expected.to include young_adult }
      it { is_expected.to include unwaged }
      it { is_expected.to include child }
      it { is_expected.to_not include silver_fern }
    end

    context "when silver_fern" do
      let(:from) { "silver_fern" }
      it { is_expected.to include adult }
      it { is_expected.to_not include young_adult }
    end

    context "when kiwi" do
      let(:from) { "kiwi" }
      it { is_expected.to include adult }
      it { is_expected.to include young_adult }
      it { is_expected.to_not include silver_fern }
    end
  end

  context "checking the cost of upgrades" do
    subject(:result) { query.call }

    context "when young adult" do
      let(:from) { "young_adult" }

      it "costs the difference when upgrading to adult" do
        expect(result.first.price).to be(adult.price - young_adult.price)
      end
    end
  end
end
