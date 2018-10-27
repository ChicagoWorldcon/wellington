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

RSpec.describe ChargeCustomer do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  let(:membership) { create(:membership) }
  let(:user) { create(:user) }
  let(:token) { stripe_helper.generate_card_token }

  context "when paying for a membership" do
    subject(:command) { ChargeCustomer.new(membership, user, token) }

    context "when payment fails" do
      before do
        StripeMock.prepare_card_error(:card_declined)
        expect(command.call).to be_falsey
      end

      it "creates a failed payment on card decline" do
        expect(Charge.failed.count).to eq 1
        expect(Charge.last.stripe_id).to be_present
        expect(Charge.last.comment).to match(/Declined/i)
        expect(membership.state).to eq(Membership::INSTALLMENT)
      end
    end

    context "when payment succeeds" do
      before do
        expect(command.call).to be_truthy
      end

      it "creates a new successful charge" do
        expect(Charge.succeeded.count).to eq(1)
        expect(Charge.last.stripe_id).to be_present
      end

      it "is linked to our user" do
        expect(Charge.last.user).to eq user
      end
    end
  end

  context "when paying only part of a membership" do
    let(:amount_paid) { membership.worth / 4 }
    subject(:command) { ChargeCustomer.new(membership, user, token, charge_amount: amount_paid) }

    it "creates a failed payment on card decline" do
      StripeMock.prepare_card_error(:card_declined)
      expect(command.call).to be_falsey
      expect(Charge.failed.count).to eq 1
      expect(Charge.last.stripe_id).to be_present
      expect(Charge.last.comment).to match(/Declined/i)
      expect(Charge.last.cost).to be(amount_paid)
    end

    context "when payment succeeds" do
      before do
        expect(command.call).to be_truthy
      end

      it "creates a new successful charge" do
        expect(Charge.succeeded.count).to eq(1)
        expect(Charge.last.stripe_id).to be_present
      end

      it "is of the value passsed in" do
        expect(Charge.last.cost).to be(amount_paid)
      end

      it "marks membership state as installment" do
        expect(membership.state).to eq Membership::INSTALLMENT
      end
    end
  end

  context "when overpaying" do
    let(:amount_paid) { membership.worth + 1 }
    subject(:command) { ChargeCustomer.new(membership, user, token, charge_amount: amount_paid) }

    it "refuses to purchase the membership" do
      expect(command.call).to be_falsey
      expect(command.errors).to include(/Overpay/i)
    end
  end

  context "when paying off a membership" do
    let(:first_payment) { membership.worth / 4 }
    let(:final_payment) { membership.worth - first_payment }

    it "transitions from installment to active" do
      expect {
        ChargeCustomer.new(membership, user, token, charge_amount: first_payment).call
      }.to change { Charge.count }.by(1)

      expect(membership.state).to eq Membership::INSTALLMENT

      expect {
        ChargeCustomer.new(membership, user, token, charge_amount: final_payment).call
      }.to change { Charge.count }.by(1)

      expect(membership.state).to eq Membership::ACTIVE
    end
  end
end
