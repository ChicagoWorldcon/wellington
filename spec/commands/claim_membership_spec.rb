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

RSpec.describe ClaimMembership do
  let(:membership_number) { nil }
  let(:membership) { create(:membership, :adult) }
  let(:user) { create(:user) }
  let(:command) { ClaimMembership.new(membership, customer: user, membership_number: membership_number) }

  context "when successful" do
    it "returns true" do
      expect(command.call).to be_truthy
    end

    it "creates a reservation and gives a claim to the user" do
      expect { command.call }.to change { user.reload.active_claims.count }.by(1)
    end

    it "creates an order against the membership" do
      expect { command.call }.to change { membership.reload.active_orders.count }.by(1)
    end

    it "doesn't charge customer" do
      expect { command.call }.to_not change { Charge.count }
    end

    it "sets reservation to instalment" do
      command.call
      expect(Reservation.last).to be_instalment
    end

    it "gives us room to add guest of honor and staff" do
      command.call
      expect(Reservation.last.membership_number).to eq(100)
    end

    context "with a zero cost membership" do
      let(:membership) { create(:membership, :kidit) }

      it "sets reservation to paid" do
        command.call
        expect(Reservation.last).to be_paid
      end
    end

    context "when given a membership number" do
      let(:membership_number) { 7480 }

      it "sets the membership number" do
        command.call
        expect(Reservation.last.membership_number).to eq membership_number
      end
    end

    context "when not given a membership number" do
      it "increments membership numbers" do
        command.call
        command.call
        expect(Reservation.second.membership_number - Reservation.first.membership_number).to be 1
      end
    end
  end
end
