# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2020 Victoria Garcia
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

RSpec.describe Membership, type: :model do

  before(:all) do
    puts "#{Membership.all.count} Memberships at the start"
  end

  after(:all) do
    puts "#{Membership.all.count} Memberships left after everything"
  end

  subject(:model) { create(:membership, :adult, :with_order_for_reservation) }

  it { is_expected.to be_valid }

  describe "#active_reservations" do
    it "can access reservations directly" do
      expect(model.reservations.count).to be(1)
    end

    it "doesn't list reservations that become inactive" do
      model.orders.update_all(active_to: 1.minute.ago)
      expect(model.reservations.count).to be(0)
    end
  end

  describe "#active_at" do
    let(:membership_available_at) { 1.month.ago }
    let(:membership_inactive_from) { membership_available_at + 1.week }
    let(:our_membership) { create(:membership, :adult, active_from: membership_available_at, active_to: membership_inactive_from) }

    subject(:scope) { Membership.active_at(time) }

    context "just before membership is available" do
      let(:time) { membership_available_at - 1.second }
      it { is_expected.to_not include(our_membership) }
    end

    context "as the membership becomes available" do
      let(:time) { membership_available_at }
      it { is_expected.to include(our_membership) }
    end

    context "just before membership becomes inactive" do
      let(:time) { membership_inactive_from - 1.second }
      it { is_expected.to include(our_membership) }
    end

    context "as the membership becomes inactive" do
      let(:time) { membership_inactive_from }
      it { is_expected.to_not include(our_membership) }
    end
  end

  describe "#to_s" do
    context "when kid-in-tow" do
      let(:k_memb) { create(:membership, :kidit) }

      it "reports the correct string" do
        expect(k_memb.to_s).to eq("Kid-in-Tow")
      end
    end

    context "when YA" do
      let(:y_memb) { create(:membership, :ya) }

      it "reports the correct string" do
        expect(y_memb.to_s).to eq("YA (16-25)")
      end
    end

    context "when supporting" do
      let(:s_memb) { create(:membership, :supporting) }

      it "reports the correct string" do
        expect(s_memb.to_s).to eq("Supporting")
      end
    end
  end

  describe "#all_rights" do
    subject(:all_rights) { model.all_rights }

    it { is_expected.to include("rights.attend") }
    it { is_expected.to include("rights.hugo.vote") }
    it { is_expected.to include("rights.hugo.nominate") }
    it { is_expected.to include("rights.site_selection") }

    context "for chid" do
      let(:model) { create(:membership, :child, :with_order_for_reservation) }

      it { is_expected.to include("rights.attend") }
      it { is_expected.to_not include("rights.hugo.vote") }
    end
  end

  describe "#dob_required?" do
    subject(:dob_required?) { model.dob_required? }
    it { is_expected.to equal false }

    context "for supporting" do
      let(:model) { create(:membership, :supporting) }
      it { is_expected.to equal false}
    end

    context "for kid-in-tow" do
      let(:model) { create(:membership, :kidit) }
      it { is_expected.to equal true }
    end

    context "for child" do
      let(:model) { create(:membership, :child) }
      it { is_expected.to equal true}
    end

    context "for young adult" do
      let(:model) { create(:membership, :ya) }
      it { is_expected.to equal true }
    end
  end
end
