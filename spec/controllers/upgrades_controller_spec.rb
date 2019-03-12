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

RSpec.describe UpgradesController, type: :controller do
  let!(:silver_fern_membership) { create(:membership, :silver_fern) }
  let!(:adult_membership) { create(:membership, :adult) }
  let!(:purchase) { create(:purchase, :with_claim_from_user, membership: silver_fern_membership) }

  let(:offer) { UpgradeOffer.new(from: silver_fern_membership, to: adult_membership) }
  let(:user_pays_path) { new_charge_path(purchaseId: purchase.id) }

  describe "#edit" do
    # shallow checks, also tested by purchases_controller_spec for things like transferred membership
    it "fails to find record when you're not signed in" do
      expect { put :edit, params: { id: purchase.id } }
        .to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when signed in" do
      before { sign_in(purchase.user) }

      it "requires you submit offer text in params" do
        put :edit, params: { id: purchase.id }
        expect(response).to redirect_to(purchases_path)

        expect(purchase.reload.membership).to eq(silver_fern_membership)
        expect(flash[:error]).to match(/sorry/i)
      end

      it "fails if the offer changes" do
        put :edit, params: { id: purchase.id, offer: "Upgrade to Adult ($1.00 NZD)" }
        expect(response).to redirect_to(purchases_path)

        expect(purchase.reload.membership).to eq(silver_fern_membership)
        expect(flash[:error]).to match(/sorry/i)
      end

      it "upgrades your membership when available" do
        put :edit, params: { id: purchase.id, offer: offer.to_s }
        expect(response).to redirect_to(user_pays_path)

        expect(purchase.reload.membership).to eq(offer.to_membership)
        expect(flash[:notice]).to match(/reserved/i)
      end
    end
  end
end
