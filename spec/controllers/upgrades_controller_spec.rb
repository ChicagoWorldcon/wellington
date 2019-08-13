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
  let!(:reservation) { create(:reservation, :with_claim_from_user, membership: silver_fern_membership) }
  let!(:offer) { UpgradeOffer.new(from: silver_fern_membership, to: adult_membership) }
  let!(:user_pays_path) { new_reservation_charge_path(reservation) }

  let(:old_offer) { UpgradeOffer.new(from: silver_fern_membership, to: old_adult_membership) }
  let(:old_adult_membership) do
    create(:membership, :adult,
      active_to: 1.second.ago,
      price: adult_membership.price - Money.new(1_00)
    )
  end

  describe "#index" do
    render_views

    subject(:get_index) { get :index, params: { reservation_id: reservation.id } }

    it "doesn't render when signed out" do
      expect { get_index }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "doesn't render when signed in user doesn't own the membership" do
      sign_in(create(:user))
      expect { get_index }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when the user is signed in" do
      before do
        sign_in(reservation.user)
      end

      it "renders happily" do
        get_index
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "#create" do
    # shallow checks, also tested by reservations_controller_spec for things like transferred membership
    it "fails to find record when you're not signed in" do
      expect { put :create, params: { id: reservation.id } }
        .to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when signed in" do
      before { sign_in(reservation.user) }

      it "requires you submit offer text in params" do
        put :create, params: { id: reservation.id }
        expect(response).to redirect_to(reservations_path)

        expect(reservation.reload.membership).to eq(silver_fern_membership)
        expect(flash[:error]).to match(/sorry/i)
      end

      it "fails if the offer changes" do
        price_change_at = 1.second.ago
        adult_membership.dup.update!(
          active_from: price_change_at,
          price: adult_membership.price + Money.new(50_00),
        )
        adult_membership.update!(active_to: price_change_at)

        put :create, params: { id: reservation.id, offer: old_offer.hash }
        expect(response).to redirect_to(reservations_path)

        expect(reservation.reload.membership).to eq(silver_fern_membership)
        expect(flash[:error]).to match(/sorry/i)
      end

      it "upgrades your membership when available" do
        put :create, params: { id: reservation.id, offer: offer.hash }
        expect(response).to redirect_to(user_pays_path)

        expect(reservation.reload.membership).to eq(offer.to_membership)
        expect(flash[:notice]).to match(/upgraded/i)
      end
    end
  end

  describe "#new" do
    context "when signed in" do
      before { sign_in(reservation.user) }

      it "fails if the offer changes" do
        put :new, params: { id: reservation.id, offer: old_offer.hash }
        expect(response).to redirect_to(reservations_path)

        expect(reservation.reload.membership).to eq(silver_fern_membership)
        expect(flash[:error]).to match(/sorry/i)
      end
    end
  end
end
