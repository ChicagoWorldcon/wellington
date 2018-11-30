# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
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

RSpec.describe PurchaseMembership do
  let(:membership) { create(:membership, :adult) }
  let(:user) { create(:user) }
  let(:command) { PurchaseMembership.new(membership, customer: user) }

  context "when successful" do
    it "returns true" do
      expect(command.call).to be_truthy
    end

    it "creates a purchase and gives a claim to the user" do
      expect { command.call }.to change { user.reload.active_claims.count }.by(1)
    end

    it "creates an order against the membership" do
      expect { command.call }.to change { membership.reload.active_orders.count }.by(1)
    end

    it "increments membership numbers" do
      command.call
      command.call
      expect(Purchase.second.membership_number - Purchase.first.membership_number).to be 1
    end
  end
end
