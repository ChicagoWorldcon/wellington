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

RSpec.describe MergeMembership do
  let(:us) { create(:user) }
  let(:them) { create(:user) }
  let(:reservation_1) { create(:reservation) }
  let(:reservation_2) { create(:reservation) }

  subject(:command) { described_class.new([reservation_1, reservation_2]) }

  describe "#call" do
    subject(:call) { command.call }

    let(:reservation_1) { create(:reservation, user: us) }
    let(:reservation_2) { create(:reservation, user: us) }

    before do
      reservation_1.active_claim.update!(active_from: 1.day.ago)
      reservation_2.active_claim.update!(active_from: 1.day.ago)
    end

    it { is_expected.to be_truthy }

    it "doesn't have errors" do
      expect { call }.to_not change { command.errors.count }.from(0)
    end

    it "removes one membership from us" do
      expect { call }
        .to change { us.reservations.count }
        .by(-1)
    end

    it "fails when less or more than 2 memberships " do
      command = described_class.new([reservation_1])
      expect(command.call).to be_falsey
      expect(command.errors).to include(/2 memberships/i)

      command = described_class.new([reservation_1, reservation_1, reservation_1])
      expect(command.call).to be_falsey
      expect(command.errors).to include(/2 memberships/i)
    end

    context "when owned by differnet people" do
      let(:reservation_1) { create(:reservation, user: us) }
      let(:reservation_2) { create(:reservation, user: them) }

      it { is_expected.to be_falsey }

      it "mentions context in it's errors" do
        expect { call }.to change { command.errors }.to include(/owned by the same user/i)
      end
    end
  end
end
