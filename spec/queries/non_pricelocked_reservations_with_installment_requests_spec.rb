# frozen_string_literal: true

# Copyright 2022 Victoria Garcia
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

RSpec.describe NonPricelockedReservationsWithInstallmentRequests do
  describe "#call" do
    subject(:call) { described_class.new.call }

    let(:reservation) { create(:reservation, :with_order_against_membership, :with_claim_from_user) }
    let(:contact) { reservation.active_claim.contact }

    it { is_expected.to_not be_present }

    context "when installments have been requested" do
      before do
        contact.update_attribute(:installment_wanted, true)
      end

      it "finds the reservation" do
        expect(call.size).to be(1)
        expect(call.first.id).to eq(reservation.id)
      end

      it "finds the new price_lock_date" do
        expect(call.first.new_price_lock_date).to eq(contact.created_at)
      end

      context "when the reservation already has a price lock date" do
        before do
          contact.update_attribute(:installment_wanted, true)
          reservation.update_attribute(:price_lock_date, Time.now - 1.week)
        end

        it "does not find a reservation" do
          expect(call.size).to be(0)
        end
      end

      context "when the reservation does not have an active claim" do
        before do
          contact.update_attribute(:installment_wanted, true)
          reservation.update_attribute(:price_lock_date, nil)
          reservation.active_claim.update_attribute(:active_to, Time.now - 1.week)
        end

        it "does not find a reservation" do
          expect(call.size).to be(0)
        end
      end
    end
  end
end
