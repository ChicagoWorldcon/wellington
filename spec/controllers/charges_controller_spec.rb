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

RSpec.shared_context "selected reservation" do
  let(:reservation) { create(:reservation, :with_order_against_membership, :with_claim_from_user, :instalment, instalment_paid: 0) }
  let(:reservations) { [reservation] }
  let(:user) { reservation.user }
  let(:total_price) {
    reservations.map{ |r| AmountOwedForReservation.new(r).amount_owed }.sum
  }
end

RSpec.shared_context "multiple reservations" do
  let(:reservations) {
    user = create(:user)
    create_list(:reservation, 3, :with_order_against_membership, :with_claim_for_user, :instalment, user: user, instalment_paid: 0)
  }
  let(:total_price) {
    reservations.map{ |r| AmountOwedForReservation.new(r).amount_owed }.sum
  }
  let(:user) { reservations[0].user }
end

RSpec.describe ChargesController, type: :controller do
  before { sign_in(user) }

  describe "#new" do
    include_context "selected reservation"

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

        expect(response).to render_template(:new_for_reservation)
      end

      it "sets a single pending charge" do
        get :new, params: { reservation_id: reservation.id }

        expect(assigns(:pending_charge)).to_not be(nil)
      end

      it "sets all needed attributes on the pending charge" do
        get :new, params: { reservation_id: reservation.id }

        expect(assigns(:pending_charge)).to have_attributes(
          :reservation => reservation,
          :membership => reservation.membership,
          :outstanding_amount => reservation.membership.price,
        )

        expect(assigns(:pending_charge).price_options).not_to be_empty
      end

      it "sets the outstanding amount to the total owing" do
        get :new, params: { reservation_id: reservation.id }
        expect(assigns(:outstanding_amount)).to eq(total_price)
      end

    end
  end

  describe "#new without id" do
    include_context "multiple reservations"

    context "when the reservations are all paid" do
      before { reservations.each{ |r| r.update!(state: Reservation::PAID ) }}

      it "redirects to the reservations controller" do
        get :new

        expect(response).to redirect_to(reservations_path)
      end
    end

    context "when any reservation needs to be paid" do
      it "renders the new template" do
        get :new

        expect(response).to render_template(:new)
      end

      it "sets @pending_charges for the charges" do
        get :new

        reservations.each do |r|
          expect(assigns(:pending_charges)).to include(have_attributes(:reservation => r))
        end
      end

      it "sets the outstanding amount to the total owing" do
        get :new
        expect(assigns(:outstanding_amount)).to eq(total_price)
      end

    end

  end

  describe "reservation/charges/#create" do
    include_context "selected reservation"

    let(:amount_posted) { amount_owed.cents }
    let(:amount_owed) { reservation.membership.price }
    let(:allowed_payment_amounts ) { PaymentAmountOptions.new(amount_owed).amounts }
    let(:stripe_token) { "stripe-token" }
    let(:params) do
      {
        reservation_ids: [reservation.id],
        stripeToken: stripe_token,
        amount: amount_posted,
      }
    end

    let(:charge) do
      create(:charge,
        amount_cents: amount_posted,
        user: user,
        reservations: [reservation],
      )
    end

    before do
      # We're not going to assert what type of email was sent.
      # If this becomes more complex, please do make assertions on this.
      allow(PaymentMailer).to receive_message_chain(:instalment, :deliver_later).and_return(true)
      allow(PaymentMailer).to receive_message_chain(:paid, :deliver_later).and_return(true)
      allow(PaymentMailer).to receive_message_chain(:paid_one, :deliver_later).and_return(true)
    end

    context "when the charge amount is not allowed" do
      let(:charge_success) { false }
      let(:amount_posted) { 90_00 }

      it "sets a flash error" do
        post :create, params: params

        expect(flash[:error]).to match(/provided payment amounts/)
      end

      it "redirects to the new charge path" do
        from new_reservation_charge_path(reservation_id: reservation)
        post :create, params: params

        expect(response).to redirect_to(new_reservation_charge_path(reservation_id: reservation))
      end
    end

    context "when the charge is made" do
      let(:service_response) do
        instance_double(Money::ChargeCustomer,
          call: charge_success,
          charge: charge,
          error_message: "error"
       )
      end

      before do
        # we use the do form of the return value to late bind the charge creation until we call this. Otherwise, we need
        # to test-double all of the value calculations, which is fragile and precludes us using them in configuring the
        # spec itself.
        expect(Money::ChargeCustomer)
          .to receive(:new) do
            service_response
          end
      end

      context "when the charge is unsuccessful" do
        let(:charge_success) { false }
        before { post :create, params: params }

        it "sets a flash error" do
          expect(flash[:error]).to be_present
        end

        it "redirects to the new charge form" do
          expect(response).to redirect_to(charges_path)
        end
      end

      context "when the charge is successful" do
        let(:charge_success) { true }
        let(:mail) { instance_double(ActionMailer::MessageDelivery, deliver_later: nil) }

        context "when the charge is the first for a reservation" do
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
          let(:amount_posted) {
            # We already post the first installment in the `before` hook. So, let's zero out the reservation.
            (amount_owed - allowed_payment_amounts[0]).cents
          }
          before do
            create(:charge, amount_cents: allowed_payment_amounts[0].cents, reservations: [reservation], user: user)
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

  describe "#create" do
    include_context "multiple reservations"

    let(:amount_posted) { total_price }
    let(:amount_owed) { total_price }
    let(:stripe_token) { "stripe-token" }
    let(:params) do
      {
        stripeToken: stripe_token,
        amount: amount_posted,
      }
    end

    context "when the charge is successful" do
      it "creates a charge record for each reservation in the call" do
        expect { post :create, params: params }.to change{ Charge.count }.by(reservations.count)
      end

      it "redirects to the home page" do
        post :create, params: params
        expect(response).to redirect_to(root_path)
      end

      it "flashes a success message" do
        pending("implementing this logic")
        post :create, params: params
        fail
      end

      it "sends a charge email" do
        expect(PaymentMailer).to receive(:paid).with("something")
        post :create, params: params
      end
    end

    context "the charge is successful for the wrong amount" do
      it "applies the charge in order to the outstanding amounts" do
        pending("implementing this logic")
        post :create, params: params
        fail
      end

      it "flashes an error" do
        pending("implementing this logic")
        post :create, params: params
        fail
      end

      it "emails the admins" do
        pending("implementing this logic")
        post :create, params: params
        fail
      end
    end

    context "when the charge is unsuccessful" do
      let(:charge_success) { false }

      it "sets a flash error" do
        post :create, params: params
        expect(flash[:error]).to be_present
      end

      it "redirects back to the charges page" do
        post :create, params: params
        expect(response).to redirect_to(charge_path)
      end
    end
  end
end
