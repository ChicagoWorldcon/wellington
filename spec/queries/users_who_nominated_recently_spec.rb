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

RSpec.describe UsersWhoNominatedRecently do
  describe "#call" do
    subject(:call) { described_class.new.call }
    let(:reservation) { create(:reservation, :with_order_against_membership, :with_claim_from_user) }
    let(:user) { reservation.user }

    it { is_expected.to_not be_present }

    it "detects when a user nominated" do
      reservation.nominations << create(:nomination, created_at: 20.minutes.ago)
      expect(call).to include(user)
    end
  end
end
