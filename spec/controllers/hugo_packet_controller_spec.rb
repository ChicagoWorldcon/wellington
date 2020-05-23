# frozen_string_literal: true

# Copyright 2020 Steven Ensslen
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

require 'rails_helper'

RSpec.describe HugoPacketController, type: :controller do
  render_views

  let(:adult) { create(:membership, :adult) }
  let(:dublin) { create(:membership, :dublin_2019) }

  describe "#index" do
    context "when logged out" do
      it "redirects with error" do
        expect(get :index).to redirect_to(root_path)
        expect(flash[:notice]).to match(/please log in/i)
      end
    end

    context "when logged in without voting rights" do
      let(:reservation) { create(:reservation, :with_claim_from_user, membership: dublin) }
      before { sign_in(reservation.user) }

      it "redirects with error" do
        expect(get :index).to redirect_to(reservations_path)
        expect(flash[:notice]).to match(/please upgrade/i)
      end
    end

    context "when logged with voting rights" do
      let(:reservation) { create(:reservation, :with_claim_from_user, membership: adult) }
      before { sign_in(reservation.user) }

      before do
        Aws.config.update(stub_responses: true)
        Aws::S3::Client.new.stub_data(:list_objects_v2,
          prefix: "/",
          contents: [],
        )
      end

      it "renders ok" do
        expect(get :index).to have_http_status(:ok)
      end
    end
  end
end
