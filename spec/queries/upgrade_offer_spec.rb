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
  let!(:ya)          { create(:membership, :ya) }
  let!(:unwaged)     { create(:membership, :unwaged) }
  let!(:child)       { create(:membership, :child) }
  let!(:kidit)       { create(:membership, :kidit) }
  let!(:supporting)  { create(:membership, :supporting) }
  let!(:silver_fern) { create(:membership, :silver_fern) }
  let!(:kiwi)        { create(:membership, :kiwi) }

  subject(:offer) { UpgradeOffer.new(from: silver_fern, to: adult) }

  before(:all) do
    puts "#{Membership.all.count} Memberships at the start"
  end

  after(:all) do
    puts "#{Membership.all.count} Memberships left after everything"
  end

  it "shows price as the difference of memberships" do
    expect(offer.price).to eq(adult.price - silver_fern.price)
  end

  it "resolves adult rights" do
    expect(offer.membership_rights).to include "rights.attend"
    expect(offer.membership_rights).to include "rights.hugo.nominate"
    expect(offer.membership_rights).to include "rights.hugo.vote"
    expect(offer.membership_rights).to include "rights.site_selection"
  end

  describe "#to_s" do
    it "reports US currency in string form" do
      expect(offer.to_s).to match(/\d+/i)
      expect(offer.to_s).to include($currency)
    end
  end

  describe "#link_text" do
    it "mentions an upgrade" do
      expect(offer.link_text).to match(/Upgrade/i)
    end
  end

  describe "#link_description" do
    it "reports US currency in string form" do
      expect(offer.link_description).to match(/\d+/i)
      expect(offer.link_description).to include($currency)
    end
  end

  describe "#from" do
    let(:upgrade_offers) { UpgradeOffer.from(current_membership) }
    subject(:upgrade_offer_strings) {
      upgrade_offers.map(&:to_s) }

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
      let(:current_membership) { ya }
      it { is_expected.to include(/adult/i) }
      it { is_expected.to_not include(/unwaged/i) }
      it { is_expected.to_not include(/kid-in-tow/i) }

      context "when prices change" do
        before do
          adult.update!(active_to: 1.second.ago)
          ya.update!(active_to: 1.second.ago)
          create(:membership, :adult, price: 500_00)
          create(:membership, :ya, price: 450_00)
        end

        it { is_expected.to include(/adult/i) }
        it { is_expected.to_not include(/young adult/i) }
      end
    end

    context "when kid_in_tow" do
      let(:current_membership) { supporting }
      it { is_expected.to include(/adult/i) }
      it { is_expected.to include(/ya/i) }
      it { is_expected.to include(/unwaged/i) }
      it { is_expected.to include(/child/i) }
      it { is_expected.to_not include(/silver fern/i) }
    end

    context "when silver_fern" do
      let(:current_membership) { silver_fern }
      it { is_expected.to include(/adult/i) }
      it { is_expected.to_not include(/ya/i) }
    end

    context "when kiwi" do
      let(:current_membership) { kiwi }
      it {is_expected.to include(/adult/i) }
      it {is_expected.to include(/ya/i) }
      it {is_expected.to_not include(/silver fern/i) }
    end
  end
end
