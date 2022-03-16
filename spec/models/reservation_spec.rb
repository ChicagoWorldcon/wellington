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

RSpec.describe Reservation, type: :model do
  context "when adult" do
    subject(:model) { create(:reservation) }
    it { is_expected.to be_valid }
    it { is_expected.to be_transferable }

    it "enforces uniqueness on membership number" do
      duplicate_membership = build(:reservation, membership_number: subject.membership_number)
      expect(duplicate_membership).to_not be_valid
    end
  end

  context "with order" do
    subject(:model) { create(:reservation, :with_order_against_membership) }

    it "has access to the active order" do
      expect(model.orders.active.count).to eq 1
      expect(model.active_order).to eq model.orders.active.first
    end

    it "has access to reservation through active orders" do
      expect(model.membership).to eq model.orders.active.first.membership
    end
  end

  context "with claim" do
    subject(:model) { create(:reservation, :with_claim_from_user) }

    it "has access ot the active claim" do
      expect(model.claims.active.count).to eq 1
      expect(model.active_claim).to eq model.claims.active.first
    end

    it "has access to user through active claims" do
      expect(model.user).to eq model.claims.active.first.user
    end
  end

  context "with upgradable membership" do
    subject(:model) { create(:reservation, :with_upgradable_membership) }
    let(:supporting_membership) { Membership.find_by(name: :supporting ) || create(:membership, :supporting)}

    it "has Supporting as its active membership" do
      expect(model.membership.to_s).to eq("Supporting")
    end

    it "does not have anything logged under last_fully_paid_membership" do
      expect(model.last_fully_paid_membership).to be_nil
    end
  end

  context "with last_fully_paid_membership logged" do
    subject(:model) { create(:reservation, :with_upgradable_membership, :with_last_fully_paid_membership_logged) }

    it "has a value for last_fully_paid_membership that matches its own active membership" do
      expect(model.last_fully_paid_membership).to eq(model.membership)
    end
  end

  describe "#transferable?" do
    [Reservation::INSTALMENT, Reservation::PAID].each do |state|
      it "is true when #{state}" do
        expect(build(:reservation, state: state)).to be_transferable
      end
    end

    [Reservation::DISABLED].each do |state|
      it "is false when #{state}" do
        expect(build(:reservation, state: state)).to_not be_transferable
      end
    end
  end

  describe "#has_paid_supporting?" do
    subject(:model) { create(:reservation, :with_claim_from_user) }

    it "isn't true without transactions" do
      expect(model).to_not have_paid_supporting
    end

    it "isn't true with failed transactions" do
      expect { model.charges << create(:charge, :failed, user: model.user) }
        .to change { model.reload.charges }
        .to be_present

      expect(model).to_not have_paid_supporting
    end

    it "is true when successful transaction is present" do
      expect { model.charges << create(:charge, user: model.user) }
        .to change { model.reload.charges }
        .to be_present

      expect(model).to have_paid_supporting
    end
  end

  describe "#active_rights" do
    before do
      # this needs to be set to something.
      $nomination_opens_at = 1.day.from_now

      # these can all be nil for tests
      $nomination_closed_at = nil
      $voting_opens_at = nil
      $hugo_closed_at = nil
    end

    let(:adult_membership) { create(:membership, :adult) }
    let(:dublin_membership) { create(:membership, :dublin_2019) }
    let(:model) { create(:reservation, membership: adult_membership) }
    subject(:active_rights) { model.active_rights }

    it { is_expected.to include("rights.attend") }

    # from config/initializers/hugo.rb
    after do
      SetHugoGlobals.new.call
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
        $nomination_opens_at = 1.minute.ago
        $voting_opens_at = 1.day.from_now
        $hugo_closed_at = 2.days.from_now
      end

      it { is_expected.to_not include("rights.hugo.nominate_soon") }
      it { is_expected.to include("rights.hugo.nominate") }
      it { is_expected.to_not include("rights.hugo.vote") }

      describe "for dublin supporters" do
        let(:model) { create(:reservation, membership: dublin_membership) }
        it { is_expected.to_not include("rights.hugo.nominate") }
        it { is_expected.to include("rights.hugo.nominate_only") }

        context "when they upgrade to supporting membership after nomination closes" do
          let(:supporting_without_nomination) { create(:membership, :supporting, can_nominate: false) }

          before do
            upgrader = UpgradeMembership.new(model, to: supporting_without_nomination)
            successful = upgrader.call
            raise "couldn't upgrade membership" if !successful
          end

          it { is_expected.to be_present }
          it { is_expected.to include("rights.hugo.nominate") }
        end
      end
    end

    context "between the close of nominations and the start of voting" do
      before do
        $nomination_opens_at = 1.day.ago
        $nomination_closed_at = 1.minute.ago
        $voting_opens_at = 1.day.from_now
        $hugo_closed_at = 2.days.from_now
      end

      it { is_expected.to_not include("rights.hugo.nominate_soon") }
      it { is_expected.to_not include("rights.hugo.nominate") }
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

      describe "for dublin supporters" do
        let(:model) { create(:reservation, membership: dublin_membership) }
        it { is_expected.to_not include("rights.hugo.vote") }
      end
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
