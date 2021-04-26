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
  render_views

  let(:reservation) { create(:reservation, :with_order_against_membership, :with_claim_from_user, :instalment) }
  let(:user) { reservation.user }

  before { sign_in(user) }

  describe "#new" do
    context "when the reservation is paid for" do
      before { reservation.update!(state: Reservation::PAID) }

      it "redirects to the reservation listing page" do
        get :new, params: { reservation_id: reservation.id }

        expect(response).to redirect_to(reservations_path)
      end

      it "returns a flash notice" do
        get :new, params: { reservation_id: reservation.id }

        expect(flash[:notice]).to match(/paid/)
      end
    end

    context "when the reservation has not been paid for" do
      it "renders" do
        get :new, params: { reservation_id: reservation.id }

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "#create" do
    let(:amount_posted) { 230_00 }
    let(:amount_owed) { Money.new(230_00) }
    let(:allowed_payment_amounts) { [Money.new(amount_posted)] }
    let(:stripe_token) { "stripe-token" }
    let(:params) do
      {
        reservation_id: reservation.id,
        stripeToken: stripe_token,
        amount: amount_posted,
      }
    end

    let(:charge) do
      create(:charge,
        amount: amount_posted,
        user: user,
        buyable: reservation,
      )
    end

    before do
      amount_owed_double = instance_double(AmountOwedForReservation)
      expect(AmountOwedForReservation).to receive(:new).and_return(amount_owed_double)
      expect(amount_owed_double).to receive(:amount_owed).and_return(amount_owed)

      payment_amount_options_double = instance_double(PaymentAmountOptions)
      expect(PaymentAmountOptions).to receive(:new).and_return(payment_amount_options_double)
      expect(payment_amount_options_double).to receive(:amounts).and_return(allowed_payment_amounts)

      # We're not going to assert what type of email was sent.
      # If this becomes more complex, please do make assertions on this.
      allow(PaymentMailer).to receive_message_chain(:instalment, :deliver_later).and_return(true)
      allow(PaymentMailer).to receive_message_chain(:paid, :deliver_later).and_return(true)
    end

    context "when the charge amount is not allowed" do
      let(:charge_success) { false }
      let(:amount_posted) { 90_00 }
      let(:allowed_payment_amounts) do
        [
          Money.new(40_00),
          Money.new(80_00),
          amount_owed,
        ]
      end

      it "sets a flash error" do
        post :create, params: params

        expect(flash[:error]).to match(/provided payment amounts/)
      end

      it "redirects to the new charge path" do
        post :create, params: params

        expect(response).to redirect_to(new_reservation_charge_path(reservation_id: reservation))
      end
    end

    context "when the charge is made" do
      let(:error_service) do
        instance_double(Money::ChargeCustomer,
          call: charge_success,
          charge: charge,
          error_message: "error"
       )
      end

      before do
        expect(Money::ChargeCustomer)
          .to receive(:new)
          .and_return(error_service)
      end

      context "when the charge is unsuccessful" do
        let(:charge_success) { false }
        before { post :create, params: params }

        it "sets a flash error" do
          expect(flash[:error]).to be_present
        end

        it "redirects to the new charge form" do
          expect(response).to redirect_to(new_reservation_charge_path(reservation_id: reservation))
        end
      end

      context "when the charge is successful" do
        let(:charge_success) { true }
        let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: nil) }

        context "when the charge is the first for a reservation" do
          let(:amount_owed) { 0 }

          before do
            create(:charge, amount: 340_00, buyable: reservation, user: user)
          end

          it "redirects to the reservation" do
            post :create, params: params

            expect(response).to redirect_to(reservations_path)
          end

          it "sets a flash notice" do
            post :create, params: params

            expect(flash[:notice]).to be_present
          end
        end

        context "when the charge is the not the first for a reservation" do
          let(:amount_posted) { 130_00 }
          let(:amount_owed) { Money.new(110_00) }

          before do
            create(:charge, amount: 100_00, buyable: reservation, user: user)
            create(:charge, amount: amount_posted, buyable: reservation, user: user)
          end

          it "redirects to the reservation" do
            post :create, params: params

            expect(response).to redirect_to(reservations_path)
          end

          it "sets a flash notice" do
            post :create, params: params

            expect(flash[:notice]).to be_present
          end
        end
      end
    end
  end

  describe "POST #create_group_charge" do
    let(:stripe_token) { "stripe-token" }
    let(:buyable_cart) {create(:cart, :with_unpaid_reservation_items)}
    let(:amount_owed) { Money.new(buyable_cart.subtotal_cents) }

    let(:params) do
      {
        buyable: buyable_cart.id,
        stripeToken: stripe_token,
      }
    end

    let(:charge) do
      create(:charge,
        amount: amount_owed,
        user: buyable_cart.user,
        buyable: buyable_cart,
      )
    end

    let(:error_service) do
      instance_double(Money::ChargeCustomer,
        call: charge_success,
        charge: charge,
        error_message: "error"
     )
    end

    before do
      sign_out(user)
      sign_in(buyable_cart.user)

      allow(PaymentMailer).to receive_message_chain(:cart_paid, :deliver_later).and_return(true)

      expect(Money::ChargeCustomer)
        .to receive(:new)
        .and_return(error_service)
    end

    after do
      sign_in(user)
    end

    context "when the charge is unsuccessful" do
      let(:charge_success) { false }
      before { post :create_group_charge, params: params }

      it "sets a flash error" do
        expect(flash[:error]).to be_present
      end

      it "redirects to the cart's preview_online_purchase path" do
        expect(response).to redirect_to(cart_preview_online_purchase_path)
      end
    end

    context "when the charge is successful" do
      let(:charge_success) { true }
      let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: nil) }

      it "redirects to the group_charge_confirmation_path" do
        post :create_group_charge, params: params

        expect(response).to redirect_to :action => :group_charge_confirmation, :processed_cart => assigns(:transaction_cart), :charge => assigns(:transaction_cart).charges.order("created_at").last
      end
    end
  end

  describe "GET #group_charge_confirmation" do
    let(:fully_paid_cart) {create(:cart, :fully_paid_through_direct_charges)}
    let(:f_p_c_charge) {fully_paid_cart.charges.order("created_at").last}

    before do
      sign_in(fully_paid_cart.user)
    end

    after do
      sign_out(fully_paid_cart.user)
      sign_in(user)
    end

    context "when it doesn't recieve valid params" do
      let(:params) do
        {
          processed_cart: 2147483647,
          charge: 2147483647,
        }
      end

      before do
        get :group_charge_confirmation, params: params
      end

      it "succeeds" do
        expect(response).to have_http_status(:found)
      end

      it "redirects" do
        expect(subject).to redirect_to(:reservations)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/unable/i)
      end

      it "doesn't assign a value @amount_charged" do
        expect(assigns(:amount_charged)).to be_nil
      end

      it "assigns a value to @processed_cart" do
        expect(assigns(:processed_cart)).to be_nil
      end
    end

    context "when it receives valid params" do
      let(:params) do
        {
          processed_cart: fully_paid_cart.id,
          charge: f_p_c_charge.id,
        }
      end

      before do
        get :group_charge_confirmation, params: params
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders" do
        expect(subject).to render_template(:group_charge_confirmation)
      end

      it "assigns a value to @amount_charged" do
        expect(assigns(:amount_charged)).not_to be_nil
        expect(assigns(:amount_charged)).to be_a_kind_of(String)
      end

      it "assigns a value to @processed_cart" do
        expect(assigns(:processed_cart)).not_to be_nil
        expect(assigns(:processed_cart)).to be_a_kind_of(Cart)
        expect(assigns(:processed_cart)).to eql(fully_paid_cart)
      end
    end
  end
end
