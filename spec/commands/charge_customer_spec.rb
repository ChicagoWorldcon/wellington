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

  let(:purchase) { create(:purchase, :with_order_against_product) }
  let(:product) { purchase.product }
  let(:user) { create(:user) }
  let(:token) { stripe_helper.generate_card_token }

  context "when paying for a purchase" do
    subject(:command) { ChargeCustomer.new(purchase, user, token) }

    context "when payment fails" do
      before do
        StripeMock.prepare_card_error(:card_declined)
        expect(command.call).to be_falsey
      end

      it "creates a failed payment on card decline" do
        expect(Charge.failed.count).to eq 1
        expect(Charge.last.stripe_id).to be_present
        expect(Charge.last.comment).to match(/Declined/i)
        expect(purchase.state).to eq(Purchase::INSTALLMENT)
      end
    end

    context "when payment succeeds" do
      before do
        expect(command.call).to be_truthy
      end

      it "creates a new successful charge" do
        expect(Charge.successful.count).to eq(1)
        expect(Charge.last.stripe_id).to be_present
      end

      it "is linked to our user" do
        expect(Charge.last.user).to eq user
      end
    end
  end

  context "when paying only part of a purchase" do
    let(:amount_paid) { product.price / 4 }
    subject(:command) { ChargeCustomer.new(purchase, user, token, charge_amount: amount_paid) }

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
        expect(Charge.successful.count).to eq(1)
        expect(Charge.last.stripe_id).to be_present
      end

      it "is of the value passsed in" do
        expect(Charge.last.cost).to be(amount_paid)
      end

      it "marks purchase state as installment" do
        expect(purchase.state).to eq Purchase::INSTALLMENT
      end
    end
  end

  context "when overpaying" do
    let(:amount_paid) { product.price + 1 }
    subject(:command) { ChargeCustomer.new(purchase, user, token, charge_amount: amount_paid) }

    it "refuses to purchase the purchase" do
      expect(command.call).to be_falsey
      expect(command.errors).to include(/Overpay/i)
    end
  end

  context "when paying off a purchase" do
    let(:partial_pay) { product.price / 4 }
    let(:remainder) { product.price - partial_pay }
    let(:overpay) { remainder + 1 } # just a cent over

    before do
      ChargeCustomer.new(purchase, user, token, charge_amount: partial_pay).call
    end

    subject(:command) { ChargeCustomer.new(purchase, user, token, charge_amount: remainder) }

    it { is_expected.to be_truthy }

    it "transitions from installment" do
      expect { command.call }
        .to change { purchase.state }
        .from(Purchase::INSTALLMENT).to(Purchase::PAID)
    end

    it "creates a charge" do
      expect { command.call }
        .to change { Charge.count }
        .by(1)
    end

    context "when choosing to overpay" do
      subject(:command) { ChargeCustomer.new(purchase, user, token, charge_amount: overpay) }

      it "gives a polite error" do
        expect(command.call).to be_falsey
        expect(command.errors).to include(/Overpay/i)
      end
    end

    context "with default behaviour" do
      subject(:command) { ChargeCustomer.new(purchase, user, token) }

      it { is_expected.to be_truthy }

      it "transitions from installment" do
        expect { command.call }
          .to change { purchase.state }
          .from(Purchase::INSTALLMENT).to(Purchase::PAID)
      end

      it "only pays the price of the membership" do
        command.call
        expect(user.charges.successful.sum(:cost)).to eq product.price
      end
    end
  end
end
