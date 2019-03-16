# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 AJ Esler
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

RSpec.describe PurchasesController, type: :controller do
  include Warden::Test::Helpers
  render_views

  let!(:kid_in_tow) { create(:membership, :kid_in_tow) }
  let!(:adult) { create(:membership, :adult) }
  let!(:existing_purchase) { create(:purchase, :with_claim_from_user, membership: adult) }
  let!(:original_user) { existing_purchase.user }

  let(:another_user) { create(:user) }
  let(:support) { create(:support) }

  describe "#index" do
    it "renders" do
      sign_in(original_user)
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe "#show" do
    it "can't be found when not signed in" do
      expect { get :show, params: { id: existing_purchase.id } }
        .to raise_error(ActiveRecord::RecordNotFound)
    end

    it "cant find it when you're signed in as a different user" do
      sign_in(another_user)
      expect { get :show, params: { id: existing_purchase.id } }
        .to raise_error(ActiveRecord::RecordNotFound)
    end

    it "can find your own purchases" do
      sign_in(original_user)
      get :show, params: { id: existing_purchase.id }
      expect(response).to have_http_status(:ok)
    end

    context "when signed in as support" do
      it "can view any membership" do
        sign_in(support)
        get :show, params: { id: existing_purchase.id }
        expect(response).to have_http_status(:found)
      end
    end

    context "after transferring a membership" do
      before do
        TransferMembership.new(existing_purchase, from: original_user, to: another_user).call
      end

      it "can't be found for original user" do
        sign_in(original_user)
        expect { get :show, params: { id: existing_purchase.id } }
          .to raise_error(ActiveRecord::RecordNotFound)
      end

      it "is found for new user" do
        sign_in(another_user)
        get :show, params: { id: existing_purchase.id }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "#update" do
    before { sign_in(original_user) }

    it "updates when all values present" do
      post :update, params: {
        id: existing_purchase.id,
        detail: {
          first_name: "this",
          last_name: "is",
          address_line_1: "yolo",
          country: "valid",
        }
      }
      expect(existing_purchase.reload.active_claim.detail.address_line_1).to eq "yolo"
      expect(flash[:notice]).to match(/your details have been saved/i)
    end

    it "shows error when values not present" do
      post :update, params: {
        id: existing_purchase.id,
        detail: {
          first_name: "this",
          last_name: "is",
          address_line_1: "",
          country: "valid",
        }
      }
      expect(flash[:error]).to match(/address/i)
    end
  end

  describe "#create" do
    before { sign_in(original_user) }

    let(:valid_detail_params) do
      FactoryBot.build(:detail).slice(
        :first_name,
        :last_name,
        :publication_format,
        :address_line_1,
        :country,
      )
    end

    context "when adult offer selected" do
      let(:offer) { MembershipOffer.new(adult) }

      it "redirects to the charges page" do
        post :create, params: {
          detail: valid_detail_params,
          offer: offer.to_s,
        }
        expect(flash[:error]).to_not be_present
        expect(response.headers["Location"]).to match(/charges/)
      end
    end

    context "when free offer selected" do
      let(:offer) { MembershipOffer.new(kid_in_tow) }

      it "redirects to the purchase listing page" do
        post :create, params: {
          detail: valid_detail_params,
          offer: offer.to_s,
        }
        expect(flash[:error]).to_not be_present
        expect(response).to redirect_to(purchases_path)
      end
    end
  end
end
