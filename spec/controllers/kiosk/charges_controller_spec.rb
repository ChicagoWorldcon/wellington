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

RSpec.describe Kiosk::ChargesController, type: :controller do
  render_views

  let!(:reservation) { create(:reservation, :instalment, :with_order_against_membership, user: member_services_user) }
  let!(:member_services_user) { create(:user, email: $member_services_email) }

  before { session[:kiosk] = 1.minute.from_now }

  describe "#new" do
    subject(:get_index) do
      get :new, params: {
        reservation_id: reservation.id
      }
    end

    it "redirects to sign in when kiosk mode expires" do
      session[:kiosk] = 1.second.ago
      get_index
      expect(response).to redirect_to(new_support_session_path)
      expect(session[:kiosk]).to be_nil
    end

    it "can't find random people's reservations" do
      reservation.update!(user: create(:user))
      expect { get_index }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "finds reservation from the member_services_user" do
      get_index
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#create" do
    let(:stripe_helper) { StripeMock.create_test_helper }
    before { StripeMock.start }
    after { StripeMock.stop }
    let(:stripe_token) { stripe_helper.generate_card_token }

    let(:post_create) do
      post :create, params: {
        reservation_id: reservation.id,
        stripeToken: stripe_token,
        amount: reservation.membership.price.cents,
      }
    end

    it "creates charges" do
      expect { post_create }.to change { Charge.count }.by(1)
    end

    it "doesn't call mailers" do
      expect(PaymentMailer).to_not receive(:instalment)
      expect(PaymentMailer).to_not receive(:paid)
      post_create
    end

    it "sends us back to the next steps page" do
      post_create
      expect(response).to redirect_to(kiosk_reservation_next_steps_path(reservation))
      expect(flash[:notice]).to be_present
    end

    context "on stripe error" do
      before { StripeMock.prepare_card_error(:card_declined) }

      it "creates a failed charge" do
        expect { post_create }.to change { Charge.count }.by(1)
        expect(reservation.reload.charges.last).to be_failed
      end

      it "sends us back to the payments page with an error" do
        post_create
        expect(response).to redirect_to(new_reservation_charge_path(reservation))
        expect(flash[:error]).to be_present
      end
    end
  end
end
