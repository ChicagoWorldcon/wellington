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

RSpec.describe Kiosk::MembershipsController, type: :controller do
  render_views

  describe "#index" do
    let(:get_index) { get :index }

    it "redirects when kiosk mode expires" do
      session[:kiosk] = 1.second.ago
      get_index
      expect(response).to redirect_to(new_support_session_path)
      expect(session[:kiosk]).to be_nil
    end

    it "renders when kiosk mode active" do
      session[:kiosk] = 1.minute.from_now
      get_index
      expect(response).to have_http_status(:ok)
    end

    context "when support signed in" do
      before { sign_in create(:support) }

      it "renders" do
        get_index
        expect(response).to have_http_status(:ok)
      end

      it "sets kiosk in the session" do
        expect { get_index }.to change { session[:kiosk] }.from(nil)
      end

      it "signs out support" do
        expect { get_index }.to change { controller.support_signed_in? }.to(false)
      end
    end
  end
end
