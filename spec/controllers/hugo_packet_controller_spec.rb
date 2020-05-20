# Copyright 2020 Steven Ensslen
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

require 'rails_helper'

RSpec.describe HugoPacketController, type: :controller do
  let(:reservation) { create(:reservation, :with_order_against_membership, :with_claim_from_user) }
  let(:user) { reservation.user }

  context "when logged out" do
    before  {sign_out(user) }

    describe "#index" do
      render_views
  
      it "renders" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response.body).to have_text("login to download the hugo packet")
      end
    end
  end

  context "when logged in" do
    before { sign_in(user) }

    describe "#index" do
      render_views
  
      it "renders" do
        get :index
        expect(response).to have_http_status(:ok)
        expect(response.body).to have_text("Best Novel.zip")
      end
    end
  end

end
