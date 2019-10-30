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

RSpec.describe Membership, type: :model do
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
    let!(:our_membership) { create(:membership, :adult, active_from: membership_available_at, active_to: membership_inactive_from) }

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
    subject(:to_s) { create(:membership, :kid_in_tow).to_s }
    it { is_expected.to eq "Kid in tow" }
  end

  describe "#rights" do
    subject(:rights) { model.rights }

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

  describe "#active_rights" do
    subject(:active_rights) { model.active_rights }

    it { is_expected.to include("rights.attend") }

    # from config/initializers/hugo.rb
    after do
      $nomination_opens_at = time_from("HUGO_NOMINATIONS_OPEN_AT") || Time.now
      $voting_opens_at = time_from("HUGO_VOTING_OPEN_AT") || 1.day.from_now
      $hugo_closed_at = time_from("HUGO_CLOSED_AT") || 2.weeks.from_now
    end

    context "before nomination opens" do
      before do
        $nomination_opens_at = 1.day.from_now
        $voting_opens_at = 2.days.from_now
        $hugo_closed_at = 3.days.from_now
      end

      it { is_expected.to include("rights.hugo.nominate_soon") }
      it { is_expected.to_not include("rights.hugo.nominate") }
      it { is_expected.to_not include("rights.hugo.vote") }
    end

    context "after nomination opens" do
      before do
        $nomination_opens_at = 1.second.ago
        $voting_opens_at = 1.day.from_now
        $hugo_closed_at = 2.days.from_now
      end

      it { is_expected.to_not include("rights.hugo.nominate_soon") }
      it { is_expected.to include("rights.hugo.nominate") }
      it { is_expected.to_not include("rights.hugo.vote") }
    end

    context "when voting opens" do
      before do
        $nomination_opens_at = 1.day.ago
        $voting_opens_at = 1.second.ago
        $hugo_closed_at = 1.day.from_now
      end

      it { is_expected.to_not include("rights.hugo.nominate_soon") }
      it { is_expected.to_not include("rights.hugo.nominate") }
      it { is_expected.to include("rights.hugo.vote") }
    end

    context "when voting closes" do
      before do
        $nomination_opens_at = 2.days.ago
        $voting_opens_at = 1.day.ago
        $hugo_closed_at = 1.second.ago
      end

      it { is_expected.to_not include("rights.hugo.nominate_soon") }
      it { is_expected.to_not include("rights.hugo.nominate") }
      it { is_expected.to_not include("rights.hugo.vote") }
    end
  end
end
