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

RSpec.describe UpgradeOffer do
  let!(:adult)       { create(:membership, :adult) }
  let!(:young_adult) { create(:membership, :young_adult) }
  let!(:unwaged)     { create(:membership, :unwaged) }
  let!(:child)       { create(:membership, :child) }
  let!(:kid_in_tow)  { create(:membership, :kid_in_tow) }
  let!(:supporting)  { create(:membership, :supporting) }
  let!(:silver_fern) { create(:membership, :silver_fern) }
  let!(:kiwi)        { create(:membership, :kiwi) }

  subject(:offer) { UpgradeOffer.new(from: silver_fern, to: adult) }

  it "shows price as the difference of memberships" do
    expect(offer.price).to eq(adult.price - silver_fern.price)
  end

  it "resolves adult rights" do
    expect(offer.membership_rights).to include "rights.attend"
    expect(offer.membership_rights).to include "rights.hugo"
    expect(offer.membership_rights).to include "rights.site_selection"
  end

  describe "#to_s" do
    subject(:to_s) { offer.to_s }
    it { is_expected.to match(/\$\d+\.\d+/i) }
    it { is_expected.to include($currency) }
  end

  describe "#link_text" do
    subject(:to_s) { offer.link_text }
    it { is_expected.to match(/Upgrade/i) }
  end

  describe "#link_description" do
    subject(:to_s) { offer.link_description }
    it { is_expected.to match(/\$\d+\.\d+/i) }
    it { is_expected.to include($currency) }
  end

  describe "#from" do
    let(:upgrade_offers) { UpgradeOffer.from(current_membership) }
    subject(:upgrade_offer_strings) { upgrade_offers.map(&:to_s) }

    context "when adult" do
      let(:current_membership) { adult }
      it { is_expected.to be_empty }

      it "doesn't display adult when prices change" do
        adult.update!(active_to: 1.second.ago)
        create(:membership, :adult, price: 500_00)
        expect(subject).to be_empty
      end
    end

    context "when unwaged" do
      let(:current_membership) { unwaged }
      it { is_expected.to include(/adult/i) }
      it { is_expected.to_not include(/young adult/i) }
      it { is_expected.to_not include(/child/i) }
    end

    context "when young adult" do
      let(:current_membership) { young_adult }
      it { is_expected.to include(/adult/i) }
      it { is_expected.to_not include(/unwaged/i) }
      it { is_expected.to_not include(/kid in tow/i) }

      context "when prices change" do
        before do
          adult.update!(active_to: 1.second.ago)
          young_adult.update!(active_to: 1.second.ago)
          create(:membership, :adult, price: 500_00)
          create(:membership, :young_adult, price: 450_00)
        end

        it { is_expected.to include(/adult/i) }
        it { is_expected.to_not include(/young adult/i) }
      end
    end

    context "when kid_in_tow" do
      let(:current_membership) { supporting }
      it { is_expected.to include(/adult/i) }
      it { is_expected.to include(/young adult/i) }
      it { is_expected.to include(/unwaged/i) }
      it { is_expected.to include(/child/i) }
      it { is_expected.to_not include(/silver fern/i) }
    end

    context "when silver_fern" do
      let(:current_membership) { silver_fern }
      it { is_expected.to include(/adult/i) }
      it { is_expected.to_not include(/young adult/i) }
    end

    context "when kiwi" do
      let(:current_membership) { kiwi }
      it { is_expected.to include(/adult/i) }
      it { is_expected.to include(/young adult/i) }
      it { is_expected.to_not include(/silver fern/i) }
    end
  end
end
