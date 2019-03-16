# frozen_string_literal: true

# Copyright 2019 AJ Esler
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

RSpec.describe ChargesController, type: :controller do
  include Warden::Test::Helpers
  render_views

  let(:purchase) { create(:purchase, :with_order_against_membership, :with_claim_from_user, :pay_as_you_go) }
  let(:user) { purchase.user }

  before { sign_in(user) }

  describe "#new" do
    context "when the purchase is paid for" do
      before { purchase.update!(state: Purchase::PAID) }

      it "redirects to the purchase listing page" do
        get :new, params: { purchaseId: purchase.id }

        expect(response).to redirect_to(purchases_path)
      end

      it "returns a flash notice" do
        get :new, params: { purchaseId: purchase.id }

        expect(flash[:notice]).to match /paid/
      end
    end

    context "when the purchase has not been paid for" do
      it "renders" do
        get :new, params: { purchaseId: purchase.id }

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "#create" do
    let(:amount) { 230_00 }
    let(:amount_owed) { 230_00 }
    let(:allowed_payment_amounts) { [amount] }
    let(:stripe_token) { "stripe-token" }
    let(:params) do
      {
        stripeToken: stripe_token,
        amount: amount,
        purchaseId: purchase.id,
      }
    end
    let(:charge_double) { instance_double(Charge, amount: amount) }

    before do
      amount_owed_double = instance_double(AmountOwedForPurchase)
      expect(AmountOwedForPurchase).to receive(:new).and_return(amount_owed_double)
      expect(amount_owed_double).to receive(:amount_owed).and_return(amount_owed)

      payment_amount_options_double = instance_double(PaymentAmountOptions)
      expect(PaymentAmountOptions).to receive(:new).and_return(payment_amount_options_double)
      expect(payment_amount_options_double).to receive(:amounts).and_return(allowed_payment_amounts)

      # We're not going to assert what type of email was sent.
      # If this becomes more complex, please do make assertions on this.
      allow(PaymentMailer).to receive_message_chain(:installment, :deliver_later).and_return(true)
      allow(PaymentMailer).to receive_message_chain(:paid, :deliver_later).and_return(true)
    end

    context "when the charge amount is not allowed" do
      let(:charge_success) { false }
      let(:amount) { 90_00 }
      let(:allowed_payment_amounts) { [40_00, 80_00, amount_owed] }

      it "sets a flash error" do
        post :create, params: params

        expect(flash[:error]).to match(/provided payment amounts/)
      end

      it "redirects to the new charge path" do
        post :create, params: params

        expect(response).to redirect_to(new_charge_path(purchaseId: purchase.id))
      end
    end

    context "when the charge is made" do
      before do
        expect(ChargeCustomer).to receive(:new).with(purchase, user, stripe_token, amount_owed, charge_amount: amount).and_return(instance_double(ChargeCustomer, call: charge_success, charge: charge_double, error_message: "error"))
      end

      context "when the charge is unsuccessful" do
        let(:charge_success) { false }
        before { post :create, params: params }

        it "sets a flash error" do
          expect(flash[:error]).to be_present
        end

        it "redirects to the new charge form" do
          expect(response).to redirect_to(new_charge_path(purchaseId: purchase.id))
        end
      end

      context "when the charge is successful" do
        let(:charge_success) { true }
        let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: nil) }

        context "when the charge is the first for a purchase" do
          let(:amount_owed) { 0 }

          before do
            create(:charge, amount: 340_00, purchase: purchase, user: user)
          end

          it "redirects to the purchase" do
            post :create, params: params

            expect(response).to redirect_to(purchases_path)
          end

          it "sets a flash notice" do
            post :create, params: params

            expect(flash[:notice]).to be_present
          end
        end

        context "when the charge is the not the first for a purchase" do
          let(:amount) { 130_00 }
          let(:amount_owed) { 110_00 }

          before do
            create(:charge, amount: 100_00, purchase: purchase, user: user)
            create(:charge, amount: amount, purchase: purchase, user: user)
          end

          it "redirects to the purchase" do
            post :create, params: params

            expect(response).to redirect_to(purchases_path)
          end

          it "sets a flash notice" do
            post :create, params: params

            expect(flash[:notice]).to be_present
          end
        end
      end
    end
  end
end
