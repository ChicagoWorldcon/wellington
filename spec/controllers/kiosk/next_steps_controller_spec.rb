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

RSpec.describe Kiosk::NextStepsController, type: :controller do
  render_views

  describe "#index" do
    let!(:reservation) { create(:reservation, :with_order_against_membership, user: member_services_user) }
    let!(:member_services_user) { create(:user, email: $member_services_email) }

    subject(:get_index) do
      get :index, params: {
        reservation_id: reservation.id
      }
    end

    it "can't find random people's reservations" do
      reservation.update!(user: create(:user))
      expect { get_index }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "finds resrvation from the member_services_user" do
      get_index
      expect(response).to have_http_status(:ok)
    end
  end
end
