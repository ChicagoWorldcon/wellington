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

RSpec.describe Operator::CreditsController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:support) { create(:support) }
  let(:reservation) do
    create(:reservation,
      :with_order_against_membership,
      :with_claim_from_user,
      :instalment,
      instalment_paid: 0,
    )
  end

  describe "#new" do
    subject(:get_new) do
      get :new, params: { reservation_id: reservation.id }
    end

    it "doesn't render when signed out" do
      get_new
      expect(response).to redirect_to(new_support_session_path)
    end

    it "doesn't render for users" do
      sign_in user
      get_new
      expect(response).to redirect_to(new_support_session_path)
    end

    it "works for support" do
      sign_in support
      expect(get_new).to have_http_status(:ok)
    end
  end

  describe "#create" do
    before do
      sign_in support
    end

    [
      "-1",
      "0",
      "0.001", # no love for fractional cents
    ].each do |bad_value|
      it "sets errors for #{bad_value}" do
        expect {
          post :create, params: {
            plan_credit: { amount: bad_value },
            reservation_id: reservation.id,
          }
        }.to_not change { Charge.count }
        expect(flash[:error]).to be_present
      end
    end

    [
      "0.01",
      "1",
      "100",
      "10_000",
    ].each do |good_value|
      it "creates charges for #{good_value}" do
        expect {
          post :create, params: {
            plan_credit: { amount: good_value },
            reservation_id: reservation.id,
          }
        }.to change { Charge.count }.by(1)
        expect(flash[:error]).to_not be_present
        expect(flash[:notice]).to be_present
      end
    end
  end
end
