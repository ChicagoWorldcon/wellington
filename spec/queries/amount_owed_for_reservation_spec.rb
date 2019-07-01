# frozen_string_literal: true

# Copyright 2019 AJ Esler
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

RSpec.describe AmountOwedForReservation do

  subject(:query) { described_class.new(reservation) }

  describe "#amount_owed" do
    subject(:amount_owed) { query.amount_owed }

    context "with no charges" do
      let(:reservation) { create(:reservation, :with_order_against_membership) }
      let(:membership) { reservation.membership }

      it { is_expected.to eq membership.price }
    end

    context "with some charges" do
      let(:user) { create(:user) }
      let(:claim) { create(:claim, :with_reservation, user: user) }
      let(:membership) { claim.reservation.membership }
      let(:charge_amount) { Money.new(10_00) }
      let(:reservation) { claim.reservation }

      before do
        create(:charge, user: user, reservation: claim.reservation, amount: charge_amount)
      end

      it "returns the amount owing" do
        expect(amount_owed.format).to eq (membership.price - charge_amount).format
      end

      context "where some have failed" do
        before do
          create(:charge, user: user, reservation: claim.reservation, amount: charge_amount, state: Charge::STATE_FAILED)
        end

        it "returns the amount owing" do
          expect(amount_owed.format).to eq (membership.price - charge_amount).format
        end
      end
    end
  end
end
