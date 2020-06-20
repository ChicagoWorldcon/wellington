# frozen_string_literal: true

# Copyright 2020 Victoria Garcia
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

RSpec.describe "Transfer request", :type => :request do

  let!(:support) { create(:support) }
  let!(:reservation) { create(:reservation, :with_claim_from_user, :with_order_against_membership) }
  let(:user) { create(:user) }
  let!(:new_user) { create(:user) }

  it "accepts a transferee's email address and redirects to the transfer confirmation page" do
    sign_in(support)
    post reservation_transfers_path(reservation_id:  reservation.id), params: { email: new_user.email,
    reservation_id: reservation.id}
    follow_redirect!
    expect(response.body).to include("Transferring Membership: Confirm transfer")
  end
end
