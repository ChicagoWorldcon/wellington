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

RSpec.describe TransfersController, type: :controller do
  render_views

  let!(:purchase) { create(:purchase, :with_claim_from_user, :with_order_against_membership) }
  let!(:support) { create(:support) }

  let(:new_params) do
    { purchase_id: purchase.id }
  end

  describe "#new" do
    it "bounces you if you're not logged in as support" do
      get :new, params: new_params
      expect(response).to have_http_status(:unauthorized)
    end

    context "when signed in as support" do
      before { sign_in(support) }

      it "renders with the email address of the person being transferred from" do
        get :new, params: new_params
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(purchase.user.email)
      end
    end
  end
end
