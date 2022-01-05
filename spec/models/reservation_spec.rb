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

  describe "#can_nominate?" do

    ["adult", "first", "ya", "supporting"].each do |trait_str|
      it "is true when the membership is #{trait_str}"  do
        expect(build(:reservation, ("with_order_against_" + trait_str + "_membership").to_sym).can_nominate?).to be true
      end
    end

    context "when the membership does not have nomination rights" do

      ["child", "kidit"].each do |trait_str|
        it "is false when the membership is #{trait_str}"  do
          expect(build(:reservation, ("with_order_against_" + trait_str + "_membership").to_sym).can_nominate?).to be false
        end
      end
    end
  end


  describe "#can_vote?" do

    ["adult", "first", "ya", "supporting"].each do |trait_str|
      it "is true when the membership is #{trait_str}"  do
        expect(build(:reservation, ("with_order_against_" + trait_str + "_membership").to_sym) .can_vote?).to be true
      end
    end

    context "when the membership does not have voting rights" do

      ["child", "kidit"].each do |trait_str|
        it "is false when the membership is #{trait_str} "  do
          expect(build(:reservation, ("with_order_against_" + trait_str + "_membership").to_sym) .can_vote?).to be false
        end
      end
    end
  end

  describe "can_site_select?" do

    ["adult", "first", "ya", "supporting"].each do |trait_str|
      it "is true when the membership is #{trait_str}"  do
        expect(build(:reservation, ("with_order_against_" + trait_str + "_membership").to_sym) .can_site_select?).to be true
      end
    end

    context "when the membership does not have site selection rights" do

      ["child", "kidit"].each do |trait_str|
        it "is false when the membership is #{trait_str} "  do
          expect(build(:reservation, ("with_order_against_" + trait_str + "_membership").to_sym) .can_site_select?).to be false
        end
      end
    end
  end

  describe "can_attend?" do

    ["adult", "first", "ya", "child", "kidit"].each do |trait_str|
      it "is true when the membership is #{trait_str}"  do
        expect(build(:reservation, ("with_order_against_" + trait_str + "_membership").to_sym) .can_attend?).to be true
      end
    end

    context "when the membership does not have attendance rights" do

      ["supporting"].each do |trait_str|
        it "is false when the membership is #{trait_str} "  do
          expect(build(:reservation, ("with_order_against_" + trait_str + "_membership").to_sym) .can_attend?).to be false
        end
      end
    end
  end

  describe "is_supporting?" do

    context "when the membership is anything other than supporting" do

      ["adult", "first", "ya", "child", "kidit"].each do |trait_str|
        it "is false when the membership is #{trait_str}"  do
          expect(build(:reservation, ("with_order_against_" + trait_str + "_membership").to_sym) .is_supporting?).to be false
        end
      end
    end


    context "when the membership is supporting" do

      ["supporting"].each do |trait_str|
        it "is true when the membership is #{trait_str} "  do
          expect(build(:reservation, ("with_order_against_" + trait_str + "_membership").to_sym) .is_supporting?).to be true
        end
      end
    end
  end

  describe "date_upgrade_prices_locked" do
    context "when the reservation doesn't have a price_lock_date" do
      subject(:model) { create(:reservation) }

      it "returns nil" do
        expect(model.price_lock_date).to be_nil
        expect(model.date_upgrade_prices_locked).to be_nil
      end
    end

    context "when the reservation does have a price_lock_date" do
      subject(:model) { create(:reservation) }

      before do
        model.update_attribute(:price_lock_date, Time.now)
      end

      it "returns the logged date" do
        expect(model.price_lock_date).to_not be_nil
        expect(model.date_upgrade_prices_locked).to be_within(1.day).of Time.now
        expect(model.date_upgrade_prices_locked).to be_within(1.second).of model.price_lock_date
      end
    end
  end

  describe "eval_for_upgrade_price_lock" do

    context "when there is a request for installment from the claimant" do
      subject(:model) { build(:reservation,
                                :with_order_against_supporting_membership,
                                :with_installment_request_from_claimant) }

      it "sets the lock" do
        expect(model.price_lock_date).to be_nil
        model.eval_for_upgrade_price_lock
        expect(model.price_lock_date).to be_within(1.day).of Time.now
      end

      it "is triggered by an after_create hook" do
        expect {model.save}
          .to change { model.price_lock_date }
          .from(nil)
      end

      it "causes the current date to be logged once triggered" do
        model.save
        expect(model.price_lock_date).to be_within(1.day).of Time.now
      end
    end

    context "when there is no request for installment from claimant" do
      subject(:model) { build(:reservation,
                                :with_order_against_supporting_membership) }

      it "does not set the lock" do
        expect(model.price_lock_date).to be_nil
        model.eval_for_upgrade_price_lock
        expect(model.price_lock_date).to be_nil
      end
    end

    context "when the membership is already adult attending" do
      subject(:model) { build(:reservation,
                                :with_order_against_adult_membership,
                                :with_installment_request_from_claimant) }

      it "does not set the lock" do
        expect(model.price_lock_date).to be_nil
        model.eval_for_upgrade_price_lock
        expect(model.price_lock_date).to be_nil
      end
    end

    context "when the reservation already has a price lock date" do
      subject(:model) { build(:reservation,
                                :with_order_against_supporting_membership,
                                :with_installment_request_from_claimant,
                                price_lock_date: Time.now - 30.days) }

      it "does not change the lock" do
        expect(model.price_lock_date).to be_within(1.day).of (Time.now - 30.days)

        expect{ model.eval_for_upgrade_price_lock }
          .to_not change { model.reload.price_lock_date}
      end
    end

    context "when the reservation is not a new one" do
      subject(:model) { create(:reservation,
                                :with_order_against_supporting_membership,
                                :with_installment_request_from_claimant ) }


      it "is not triggered by saving" do
        model.update(price_lock_date: nil)

        expect { model.save }
          .to_not change { model.price_lock_date }
          .from(nil)
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
        $nomination_opens_at = 1.second.ago
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
