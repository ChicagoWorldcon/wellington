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

RSpec.describe TransferMembership do
  let(:seller) { create(:user) }
  let(:buyer) { create(:user) }
  let(:membership) { create(:membership) }

  before { Grant.create!(user: seller, membership: membership, active_from: membership.created_at) }

  subject(:command) { TransferMembership.new(membership, from: seller, to: buyer) }
  let(:soonish) { 1.minute.from_now } # hack, TransferMembership is relying on Time.now which is a very small time slice

  it "doesn't change the number of memberships overall" do
    expect { command.call }.to_not change { Membership.count }
  end

  it "adds grant to buyer" do
    expect { command.call }.to change { buyer.grants.active_at(soonish).count }.by 1
  end

  it "deactivates grant on seller" do
    expect { command.call }.to change { seller.grants.active_at(soonish).count }.by -1
  end

  context "when there's transactions close together" do
    let(:this_instant) { Time.now }
    before { expect(Time).to receive(:now).at_least(1).times.and_return(this_instant) }

    it "doesn't let you transfer twice" do
      expect(command.call).to be_truthy
      expect(command.call).to be_falsey
      expect(command.errors).to include(/not transferrable/i)
      expect(Grant.count).to be 2
    end
  end
end
