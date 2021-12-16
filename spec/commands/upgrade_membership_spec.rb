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

RSpec.describe UpgradeMembership do
  let!(:membership) { create(:membership, :ya, :with_order_for_reservation) }
  let!(:upgrade_membership) { create(:membership, :adult) }
  let!(:reservation) { membership.reservations.first }

  describe "#call" do
    let(:command) { UpgradeMembership.new(reservation, to: upgrade_membership) }
    subject(:call) { command.call }

    it { is_expected.to be_truthy }

    it "creates new order" do
      expect { call }.to change { Order.count }.by(1)
    end

    it "now points at new membership" do
      expect { call }
        .to change { reservation.reload.membership }
        .to(upgrade_membership)
    end

    it "recalculates PAID state" do
      expect { call }
        .to change { reservation.reload.state }
        .from(Reservation::PAID)
        .to(Reservation::INSTALMENT)
    end

    context "when upgrade is unavailable" do
      let(:membership) { create(:membership, :adult, :with_order_for_reservation) }

      it { is_expected.to be_falsey }

      it "incldues helpful error message" do
        expect { call }
          .to change { command.errors }
          .to include(/cannot upgrade/i)
      end

      it "doesn't change orders" do
        expect { call }.to_not change { reservation.orders }
      end

      it "doesn't create new charges" do
        expect { call }.to_not change { reservation.charges }
      end
    end
  end
end
