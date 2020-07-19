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

RSpec.describe SetMembershipsController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:support) { create(:support) }
  let(:ya) { create(:membership, :ya) }
  let(:adult) { create(:membership, :adult) }
  let(:reservation) { create(:reservation, :with_claim_from_user, membership: ya) }

  describe "#index" do
    subject(:get_index) do
      get :index, params: {
        reservation_id: reservation.id,
      }
    end

    it "says no when you're not support" do
      sign_in(user)
      get_index
      expect(response).to redirect_to(new_support_session_path)
    end

    it "renders when support signed in" do
      sign_in(support)
      get_index
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#update" do
    before do
      sign_in(support)
    end

    it "raises error when membership can't be found" do
      expect {
        put :update, params: { reservation_id: reservation.id, id: -1 }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "sets membership to whatever you set" do
      expect { put(:update, params: { reservation_id: reservation.id, id: adult.id }) }
        .to change { reservation.reload.membership }
        .from(ya)
        .to(adult)

      expect(response).to redirect_to(reservation_path(reservation))
      expect(flash[:notice]).to include adult.to_s
    end
  end
end
