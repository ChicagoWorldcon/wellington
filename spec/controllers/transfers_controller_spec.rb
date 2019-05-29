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
  let!(:old_user) { purchase.user }
  let!(:new_user) { create(:user) }

  let(:new_params) do
    { purchase_id: purchase.id }
  end

  let(:update_parans) do
    {
      id: new_user.email,
      purchase_id: purchase.id,
    }
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
        expect(response.body).to include(old_user.email)
      end
    end
  end

  describe "#show" do
    it "bounces you if you're not logged in as support" do
      get :new, params: new_params
      expect(response).to have_http_status(:unauthorized)
    end

    context "when signed in as support" do
      before { sign_in(support) }

      it "renders" do
        get :show
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(old_user.email)
      end
    end
  end

  describe "#update" do
    before { sign_in(support) }
    subject(:update_purchase_transfer) { patch(:update, params: transfer_params) }

    it "transfers between users" do
      expect { update_purchase_transfer }
        .to change { purchase.reload.user }
        .from(old_user)
        .to(new_user)
    end

    it "doens't copy details" do
      expect { update_purchase_transfer }.to_not change { old_user.reload.claims.last.detail }
      expect(new_user.reload.claims.last.detail).to be_nil
    end

    context "when #copy_details is set" do
      let(:transfer_params) do
        {
          id: new_user.email,
          purchase_id: purchase.id,
          copy_details: "1",
        }
      end

      it "does copy details over" do
        expect { update_purchase_transfer }.to_not change { old_user.reload.claims.last.detail }
        expect(new_user.reload.claims.last.detail).to be_present
      end
    end

    context "when there are errors with submission" do
      before do
        purchase.update!(state: Purchase::INSTALLMENT)
        patch :update, params: transfer_params
      end

      it "sets errors" do
        expect(flash[:error]).to be_present
      end

      it "redirects back to transfers path" do
        expect(response).to redirect_to(purchases_path)
      end
    end
  end
end
