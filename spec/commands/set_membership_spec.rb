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
  let(:adult) { Membership.find_by(name: :adult) || create(:membership, :adult) }
  let(:support) { Membership.find_by(name: :support) || create(:membership, :supporting) }
  let(:ya) { Membership.find_by(name: :ya) || create(:membership, :ya) }
  let(:our_time) {Time.now}
  let(:ya_reservation) { create(:reservation, :with_claim_from_user, membership: ya) }

  let(:reservation) { create(:reservation, :with_claim_from_user, membership: adult) }
  let(:command) { described_class.new(reservation, to: support) }

  describe "#call" do
    subject(:call) { command.call }

    it { is_expected.to be_truthy }

    it "lets you downgrade the membership" do
      expect { call }
        .to change { reservation.reload.membership }
        .from(adult)
        .to(support)
    end

    it "Keeps membership set to paid off" do
      expect { call }
        .to_not change { reservation.reload.state }
        .from(Reservation::PAID)
    end

    context "when the reservation has no entry for last_fully_paid_membership" do
      context "when the original membership has been paid off" do
        it "logs the original membership as the last_fully_paid_membership" do
          expect { call }
            .to change { reservation.reload.last_fully_paid_membership }
            .from(nil)
            .to(adult)
        end
      end

      context "when no payments have been made on the original membership" do
        let(:reservation) { create(:reservation, membership: adult) }
        let(:command) { described_class.new(reservation, to: support) }
        it "does not log anything for last_fully_paid_membership" do
          expect { call }
            .to_not change { reservation.reload.last_fully_paid_membership }
            .from(nil)
        end
      end
    end

    context "when going to a more expensive membership" do
      let(:reservation) { create(:reservation, :with_claim_from_user, membership: support) }
      let(:command) { described_class.new(reservation, to: adult) }

      it "sets membership to instalment" do
        expect { call }
          .to change { reservation.reload.state }
          .from(Reservation::PAID)
          .to(Reservation::INSTALMENT)
      end
    end

    context "when the membership logged as last_fully_paid_membership is more expensive than the current (pre-call) membership" do

      before do
        ya_reservation.update!(last_fully_paid_membership: ya)
        ya_reservation.active_order.update!(active_to: our_time)
        ya_reservation.orders.create(active_from: our_time, membership: support)
        ya_reservation.reload
      end

      let(:reservation) { ya_reservation }
      let(:command) { described_class.new(reservation, to: adult) }

      it "Xhas a test that is set up as expected" do
        expect(reservation.membership).to eq(support)
        expect(reservation.last_fully_paid_membership).to eq(ya)
        expect(ya.price_cents).to be > support.price_cents
      end

      it "does not change the value of last_fully_paid_membership" do
        expect { call }
          .to_not change { reservation.reload.last_fully_paid_membership }
          .from(ya)
      end
    end
  end
end
