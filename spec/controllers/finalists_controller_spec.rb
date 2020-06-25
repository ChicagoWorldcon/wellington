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

RSpec.describe FinalistsController, type: :controller do
  render_views

  let(:reservation) { create(:reservation, :with_claim_from_user, :with_order_against_membership) }
  let(:election) { create(:election) }

  describe "show" do
    subject(:get_show) { get :show, params: params }

    let(:params) do
      {
        reservation_id: reservation.id,
        id: election.i18n_key,
      }
    end

    it "404s when not signed in" do
      expect { get_show }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when signed in, without voting rights" do
      let(:dublin) { create(:membership, :dublin_2019) }
      let(:reservation) { create(:reservation, :with_claim_from_user, membership: dublin) }

      it "bounces you with an error" do
        sign_in(reservation.user)
        expect(get_show).to redirect_to reservation_path(reservation)
        expect(flash[:notice]).to match(/voting rights/i)
      end
    end

    context "when signed in" do
      before do
        sign_in reservation.user
        expect(HugoState)
          .to receive_message_chain(:new, :has_voting_opened?)
          .and_return(true)
      end

      it { is_expected.to have_http_status(:ok) }

      it "sets content type" do
        expect(get_show.media_type).to eq "text/html"
      end

      context "in json" do
        subject(:get_show) { get :show, params: params, format: :json }

        it { is_expected.to have_http_status(:ok) }

        it "sets content type" do
          expect(get_show.media_type).to eq "application/json"
        end
      end
    end
  end
end
