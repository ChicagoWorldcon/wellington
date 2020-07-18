# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
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

RSpec.describe Operator::UsersController, type: :controller do
  let(:operator) { create(:operator) }
  let(:reservation) { create(:reservation, :with_order_against_membership, user: user) }
  let(:user) { create(:user) }

  # Enable Gloo integrations for this test
  # But turn it off after so CI doesn't try reaching out to thefantasy.network
  around do |test|
    ENV["GLOO_BASE_URL"] = "https://apitemp.thefantasy.network"
    ENV["GLOO_AUTHORIZATION_HEADER"] = "let_me_in_please"
    test.run
    ENV["GLOO_BASE_URL"] = nil
    ENV["GLOO_AUTHORIZATION_HEADER"] = nil
  end

  let(:mock_gloo_contact) do
    instance_double(GlooContact,
      :present? => true,
      :local_state => {},
      :remote_state => {},
      :in_sync? => false,
    )
  end

  render_views

  describe "#show" do
    subject(:get_show) { get(:show, params: { id: user.id }) }
    it { is_expected.to redirect_to(new_operator_session_path) }

    context "when operator signed in" do
      before { sign_in(operator) }

      it "renders" do
        expect(GlooContact).to receive(:new).and_return(mock_gloo_contact)
        expect(get_show).to have_http_status(:ok)
      end

      it "renders when gloo is down" do
        expect(GlooContact).to receive(:new).and_raise(GlooContact::ServiceUnavailable, "Kaboom!")
        expect(get_show).to have_http_status(:ok)
        expect(flash[:error]).to match(/The Fantasy Network/i)
      end
    end
  end

  describe "#update" do
    subject(:put_update) { put(:update, params: { id: user.id }) }
    it { is_expected.to redirect_to(new_operator_session_path) }

    context "when operator signed in" do
      let(:gloo_contact_mock) do
        instance_double(GlooContact,
          :save! => true,
          :local_state => {},
          :remote_state => {},
          :reservation => reservation,
        )
      end

      before do
        sign_in(operator)
        expect(GlooContact).to receive(:new).and_return(gloo_contact_mock)
      end

      it "redirects and sets message based on reservation" do
        expect(put_update).to redirect_to(operator_user_path(user))
        expect(flash[:notice]).to be_present
        expect(flash[:notice]).to include(reservation.membership_number.to_s)
      end

      context "when no reservation available" do
        let(:reservation) { nil }

        it "redirects and sets message based on reservation" do
          expect(put_update).to redirect_to(operator_user_path(user))
          expect(flash[:notice]).to be_present
          expect(flash[:notice]).to match(/disabled/i)
        end
      end
    end
  end
end
