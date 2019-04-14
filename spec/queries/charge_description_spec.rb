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

  let(:ages_ago) { 1.year.ago } # needs to be available to be purchased

  let!(:horse_membership)   { create(:membership, name: "horse", price: 100_00, active_from: ages_ago) }
  let!(:pony_membership)    { create(:membership, name: "pony", price: 200_00, active_from: ages_ago) }
  let!(:unicorn_membership) { create(:membership, name: "unicorn", price: 300_00, active_from: ages_ago) }

  let!(:owner_1) { create(:user) }
  let!(:owner_2) { create(:user) }

  let(:reserve_horse_date)  { 4.weeks.ago }
  let(:reserve_pony_date)   { 3.weeks.ago }

  before do
    # 4 weeks ago, we reserved a $100 horse and started paying down 1 day at a time
    Timecop.freeze(4.weeks.ago)
    purchase = ReservePurchase.new(horse_membership, customer: owner_1).call
    expect(purchase).to be_installment
    Stripe::ChargeCustomer.new(purchase, owner_1, stripe_helper.generate_card_token, 50_00).call
    Timecop.freeze(1.day.from_now)
    Stripe::ChargeCustomer.new(purchase, owner_1, stripe_helper.generate_card_token, 49_00).call
    Timecop.freeze(2.days.from_now)
    Stripe::ChargeCustomer.new(purchase, owner_1, stripe_helper.generate_card_token, 1_00).call
    expect(purchase).to be_paid

    # 3 weeks ago, we upgraded to a $200 pony and started paying down 1 day at a time
    Timecop.return
    Timecop.freeze(3.weeks.ago)
    UpgradeMembership.new(purchase.reload, to: pony_membership).call
    expect(purchase).to be_installment
    Timecop.freeze(1.second.from_now)
    Stripe::ChargeCustomer.new(purchase, owner_1, stripe_helper.generate_card_token, 50_00).call
    Timecop.freeze(1.day.from_now)
    Stripe::ChargeCustomer.new(purchase, owner_1, stripe_helper.generate_card_token, 50_00).call
    expect(purchase).to be_paid

    # 2 weeks ago, we transferred, upgraded to a $300 unicorn and paid it off
    Timecop.return
    Timecop.freeze(2.weeks.ago)
    TransferMembership.new(purchase, from: owner_1, to: owner_2).call
    Timecop.freeze(1.second.from_now)
    UpgradeMembership.new(purchase.reload, to: unicorn_membership).call
    Stripe::ChargeCustomer.new(purchase, owner_2, stripe_helper.generate_card_token, 100_00).call
    expect(purchase).to be_paid
  end

  # Even after all this setup, you should still be able to call on the origonal charge and get back results that look
  # like what that charge would have described

  def description(charge)
    ChargeDescription.new(charge).for_users
  end

  let(:membership_number) { ReservePurchase::FIRST_MEMBERSHIP_NUMER }

  it "describes installments on horses" do
    expect(description(Charge.first).to_s).to eq "$50.00 NZD Installment for Horse member #{membership_number}"
    expect(description(Charge.second).to_s).to eq "$49.00 NZD Installment for Horse member #{membership_number}"
    expect(description(Charge.third).to_s).to eq "$1.00 NZD Paid for Horse member #{membership_number}"
  end

  it "describes upgrades to ponys" do
    expect(description(Charge.fourth).to_s).to eq "$50.00 NZD Upgrade Installment for Pony member #{membership_number}"
    expect(description(Charge.fifth).to_s).to eq "$50.00 NZD Upgrade Paid for Pony member #{membership_number}"
  end

  it "describes transfer upgrades to unicorns" do
    expect(description(Charge.last).to_s).to eq "$100.00 NZD Upgrade Paid for Unicorn member #{membership_number}"
  end
end
