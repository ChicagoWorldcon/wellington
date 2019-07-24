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

RSpec.describe Kiosk::ReservationsController, type: :controller do
  render_views

  let!(:member_services_user) { create(:user, email: $member_services_email) }
  let!(:adult) { create(:membership, :adult) }
  let!(:offer) { MembershipOffer.new(adult) }

  describe "#new" do
    let(:get_new) do
      get :new, params: { offer: offer.hash }
    end

    it "is expected to render ok" do
      get_new
      expect(response).to have_http_status(:ok)
    end

    it "is expected to be signed in as the member_services_user" do
      expect { sign_in create(:user) }
        .to_not change { controller.current_user }
        .from(member_services_user)
    end
  end

  describe "#create" do
    let(:get_create) do
      get :create, params: {
        offer: offer.hash,
        detail: build(:detail).attributes,
      }
    end

    it "creates a new reservation" do
      expect { get_create }
        .to change { Reservation.count }
        .by(1)
    end

    it "gives created reservations to member_services" do
      expect { get_create }
        .to change { member_services_user.reload.reservations.count }
        .by(1)
    end

    it "redirects to kiosk memberships" do
      get_create
      expect(response).to redirect_to(kiosk_reservation_next_steps_path(Reservation.last))
      expect(flash[:notice]).to be_present
      expect(flash[:error]).to be_nil
    end
  end
end
