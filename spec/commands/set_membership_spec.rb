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

RSpec.describe SetMembership do
  let(:adult) { create(:membership, :adult) }
  let(:support) { create(:membership, :supporting) }
  let(:reservation) { create(:reservation, :with_claim_from_user, membership: adult) }

  let(:command) { described_class.new(reservation, to: support) }

  describe "#call" do
    subject(:call) { command.call }

    it { is_expected.to be_truthy }

    it "even lets you downgrade the membership" do
      expect { call }
        .to change { reservation.reload.membership }
        .from(adult)
        .to(support)
    end

    it "sets membership to paid off" do
      expect { call }
        .to_not change { reservation.reload.state }
        .from(Reservation::PAID)
    end

    context "when going to a larger membership" do
      let(:reservation) { create(:reservation, :with_claim_from_user, membership: support) }
      let(:command) { described_class.new(reservation, to: adult) }

      it "sets membership to instalment" do
        expect { call }
          .to change { reservation.reload.state }
          .from(Reservation::PAID)
          .to(Reservation::INSTALLMENT)
      end
    end
  end
end
