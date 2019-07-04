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

RSpec.describe CreditsController, type: :controller do
  render_views

  let(:user) { create(:user) }
  let(:support) { create(:support) }
  let(:reservation) { create(:reservation, :with_order_against_membership, :with_claim_from_user) }

  describe "#new" do
    subject(:get_new) do
      get :new, params: { reservation_id: reservation.id }
    end

    it "doesn't render when signed out" do
      get_new
      expect(get_new).to have_http_status(:unauthorized)
    end

    it "doesn't render for users" do
      sign_in user
      expect(get_new).to have_http_status(:unauthorized)
    end

    it "works for support" do
      sign_in support
      expect(get_new).to have_http_status(:ok)
    end
  end
end
