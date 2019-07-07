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

RSpec.describe ChargeDescription do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  let(:ages_ago) { 1.year.ago } # needs to be available to be reserved

  let!(:horse_membership)   { create(:membership, name: "horse", price_cents: 100_00, active_from: ages_ago) }
  let!(:pony_membership)    { create(:membership, name: "pony", price_cents: 200_00, active_from: ages_ago) }
  let!(:unicorn_membership) { create(:membership, name: "unicorn", price_cents: 300_00, active_from: ages_ago) }

  let!(:owner_1) { create(:user) }
  let!(:owner_2) { create(:user) }

  describe "#for_accounts" do
    subject(:for_accounts) { ChargeDescription.new(charge).for_accounts }

    let(:membership_number) { 5423.to_s }
    let(:charge) { create(:charge, reservation: unicorn_reservation) }

    let(:unicorn_reservation) do
      create(:reservation, :with_claim_from_user, :instalment,
        membership_number: membership_number,
        membership: unicorn_membership,
        instalment_paid: 0,
      )
    end

    context "with details" do
      let!(:user_details) { unicorn_reservation.active_claim.detail }
      it { is_expected.to include "3.00" }
      it { is_expected.to include "Instalment for" }
      it { is_expected.to include user_details.to_s }
      it { is_expected.to include "as Unicorn member" }
      it { is_expected.to include membership_number }
    end
  end

  describe "#for_users" do
    subject(:for_users) { ChargeDescription.new(charge).for_users }

    context "when charge succeeds" do
      let(:unicorn_reservation) { create(:reservation, membership: unicorn_membership, user: owner_1) }
      let(:charge) { create(:charge, reservation: unicorn_reservation) }
      it { is_expected.to_not match(/failed/i) }
    end

    context "when charge fails" do
      let(:unicorn_reservation) { create(:reservation, membership: unicorn_membership, user: owner_1) }
      let(:charge) { create(:charge, :failed, reservation: unicorn_reservation) }
      it { is_expected.to match(/failed/i) }
    end
  end

  context "integration when describing historical records" do
    let(:reserve_horse_date)  { 4.weeks.ago }
    let(:reserve_pony_date)   { 3.weeks.ago }

    before do
      # 4 weeks ago, we reserved a $100 horse and started paying down 1 day at a time
      Timecop.freeze(4.weeks.ago)
      reservation = ClaimMembership.new(horse_membership, customer: owner_1).call
      expect(reservation).to be_instalment
      Money::ChargeCustomer.new(reservation, owner_1, stripe_helper.generate_card_token, Money.new(50_00)).call
      Timecop.freeze(1.day.from_now)
      Money::ChargeCustomer.new(reservation, owner_1, stripe_helper.generate_card_token, Money.new(49_00)).call
      Timecop.freeze(2.days.from_now)
      Money::ChargeCustomer.new(reservation, owner_1, stripe_helper.generate_card_token, Money.new(1_00)).call
      expect(reservation).to be_paid

      # 3 weeks ago, we upgraded to a $200 pony and started paying down 1 day at a time
      Timecop.return
      Timecop.freeze(3.weeks.ago)
      UpgradeMembership.new(reservation.reload, to: pony_membership).call
      expect(reservation).to be_instalment
      Timecop.freeze(1.second.from_now)
      Money::ChargeCustomer.new(reservation, owner_1, stripe_helper.generate_card_token, Money.new(50_00)).call
      Timecop.freeze(1.day.from_now)
      Money::ChargeCustomer.new(reservation, owner_1, stripe_helper.generate_card_token, Money.new(50_00)).call
      expect(reservation).to be_paid

      # 2 weeks ago, we transferred, upgraded to a $300 unicorn and paid it off
      Timecop.return
      Timecop.freeze(2.weeks.ago)
      ApplyTransfer.new(reservation, from: owner_1, to: owner_2, audit_by: "sneeky octopus").call
      Timecop.freeze(1.second.from_now)
      UpgradeMembership.new(reservation.reload, to: unicorn_membership).call
      Money::ChargeCustomer.new(reservation, owner_2, stripe_helper.generate_card_token, Money.new(100_00)).call
      expect(reservation).to be_paid
    end

    # Even after all this setup, you should still be able to call on the origonal charge and get back results that look
    # like what that charge would have described

    def for_users(charge)
      ChargeDescription.new(charge).for_users
    end

    let(:membership_number) { ClaimMembership::FIRST_MEMBERSHIP_NUMER }

    it "describes instalments on horses" do
      expect(for_users(Charge.first)).to include "50.00"
      expect(for_users(Charge.second)).to include "49.00"
      expect(for_users(Charge.third)).to include "1.00"

      expect(for_users(Charge.first)).to include "Instalment with Credit Card for Horse member #{membership_number}"
      expect(for_users(Charge.second)).to include "Instalment with Credit Card for Horse member #{membership_number}"
      expect(for_users(Charge.third)).to include "Fully Paid with Credit Card for Horse member #{membership_number}"
    end

    it "describes upgrades to ponys" do
      expect(for_users(Charge.fourth)).to include "50.00"
      expect(for_users(Charge.fourth)).to include "Upgrade Instalment with Credit Card for Pony member #{membership_number}"
      expect(for_users(Charge.fifth)).to include "50.00"
      expect(for_users(Charge.fifth)).to include "Upgrade Fully Paid with Credit Card for Pony member #{membership_number}"
    end

    it "describes transfer upgrades to unicorns" do
      expect(for_users(Charge.last)).to include "100.00"
      expect(for_users(Charge.last)).to include "Upgrade Fully Paid with Credit Card for Unicorn member #{membership_number}"
    end
  end
end
