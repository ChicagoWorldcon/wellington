# Copyright 2020 Matthew B. Gray
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

require "rails_helper"

RSpec.describe GlooSync, type: :job do
  subject(:job) { described_class.new }
  let(:user) { create(:user) }
  let(:adult) { create(:membership, :adult) }

  # Enable Gloo integrations for this test
  # But turn it off after so CI doesn't try reaching out to thefantasy.network
  around do |test|
    ENV["GLOO_BASE_URL"] = "https://apitemp.thefantasy.network"
    ENV["GLOO_AUTHORIZATION_HEADER"] = "let_me_in_please"
    test.run
    ENV["GLOO_BASE_URL"] = nil
    ENV["GLOO_AUTHORIZATION_HEADER"] = nil
  end

  xit "cycles memberships on transfer" do
    last_minute_decision = create(:reservation, user: user, created_at: 1.day.ago, membership: adult)
    create(:conzealand_contact, first_name: "last minute decision", claim: last_minute_decision.active_claim)

    early_bird_reservation = create(:reservation, user: user, created_at: 365.days.ago, membership: adult)
    create(:conzealand_contact, first_name: "early bird price", claim: early_bird_reservation.active_claim)
    result = GlooContact.new(user).call
    expect(result[:display_name]).to match(/early bird price/)
    expect(result[:roles]).to include("video")

    ApplyTransfer.new(early_bird_reservation, from: user, to: create(:user), audit_by: "agile squirrel").call
    result = GlooContact.new(user.reload).call
    expect(result[:display_name]).to match(/last minute decision/)
    expect(result[:roles]).to include("video")

    ApplyTransfer.new(last_minute_decision, from: user, to: create(:user), audit_by: "agile squirrel").call
    result = GlooContact.new(user.reload).call
    expect(result[:display_name]).to be_empty
    expect(result[:roles]).to be_empty
  end
end
