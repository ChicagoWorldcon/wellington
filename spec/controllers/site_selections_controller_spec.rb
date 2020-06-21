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

RSpec.describe SiteSelectionsController, type: :controller do
  render_views

  let(:reservation) { create(:reservation, :with_claim_from_user, :with_order_against_membership) }

  describe "#show" do
    subject(:get_show) { get(:show, params: { id: reservation.id }) }

    it "raises an error when signed out" do
      expect { get_show }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when signed in" do
      before { sign_in reservation.user }
      it { is_expected.to have_http_status(:ok) }

      it "redirects if you've already got a site selection token" do
        site_selection = create(:site_selection, reservation: reservation)
        expect(get_show).to redirect_to(reservations_path)
        expect(flash[:notice]).to match(/already purchased/i)
        expect(flash[:notice]).to include(site_selection.token)
      end
    end
  end

  describe "#create" do
    subject(:post_create) do
      post(:create, params: { id: reservation.id })
    end

    context "when signed in" do
      before { sign_in reservation.user }

      it "redirects after purchase" do
        expect { post_create }.to change { SiteSelection.count }.by(1)
        expect(request).to redirect_to(reservations_path)
        expect(flash[:notice]).to match(/congratulations/i)
        expect(flash[:notice]).to include(SiteSelection.last.token)
      end

      it "doesn't create tokens if you've already purchased for site selection" do
        site_selection = create(:site_selection, reservation: reservation)

        expect { post_create }.to_not change { SiteSelection.count }
        expect(request).to redirect_to(reservations_path)
        expect(flash[:notice]).to match(/already purchased/i)
        expect(flash[:notice]).to include(site_selection.token)
      end
    end
  end
end
