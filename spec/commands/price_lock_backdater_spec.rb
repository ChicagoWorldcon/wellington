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

RSpec.describe PriceLockBackdater do

  describe "#call" do
    subject(:command) { described_class.new }

    let(:reservation_one) { create(:reservation, :with_order_against_membership, :with_claim_from_user) }
    let(:contact_one) { reservation_one.active_claim.contact }

    let(:reservation_two) { create(:reservation, :with_order_against_membership, :with_claim_from_user) }
    let(:contact_two) { reservation_two.active_claim.contact }

    let(:reservation_three) { create(:reservation, :with_order_against_membership, :with_claim_from_user) }
    let(:contact_three) { reservation_three.active_claim.contact }

    let(:reservation_four) { create(:reservation, :with_order_against_membership, :with_claim_from_user) }
    let(:contact_four) { reservation_four.active_claim.contact }


    it { is_expected.to be_present }

    context "when there are no qualifying reservations" do
      before do
        contact_one.update_attribute(:installment_wanted, false)
        contact_two.update_attribute(:installment_wanted, false)
        contact_three.update_attribute(:installment_wanted, false)
        contact_four.update_attribute(:installment_wanted, false)
      end

      it "has a properly set-up test" do
        expect(ChicagoContact.where(installment_wanted: true).any?).to eq(false)
        expect(Reservation.where.not(price_lock_date: nil).any?).to eq(false)
      end

      it "succeeds" do
        expect(command.call).to be_truthy
      end

      it "does not update any reservations" do
        expect(Reservation.where.not(price_lock_date: nil).any?).to eq(false)
      end
    end

    context "when all reservations qualify" do

      before do
        contact_one.update_attribute(:installment_wanted, true)
        contact_two.update_attribute(:installment_wanted, true)
        contact_three.update_attribute(:installment_wanted, true)
        contact_four.update_attribute(:installment_wanted, true)
      end

      it "has a properly set-up test" do
        expect(ChicagoContact.where.not(installment_wanted: true).any?).to eq(false)
        expect(Reservation.where.not(price_lock_date: nil).any?).to eq(false)
      end

      it "returns true" do
        expect(command.call).to be_truthy
      end

      it "assigns price_lock_date values to all reservations" do
        command.call
        expect(Reservation.where(price_lock_date: nil).any?).to eq(false)
      end

      it "results updates all reservations such that no reservations that qualify for backdated price_lock_dates remain" do

        command.call

        expect(NonPricelockedReservationsWithInstallmentRequests.new.call.any?).to eq(false)
      end
    end

    context "when only a fraction of reservations qualify" do

      before do
        contact_one.update_attribute(:installment_wanted, true)
        contact_two.update_attribute(:installment_wanted, true)
        contact_three.update_attribute(:installment_wanted, false)
        contact_four.update_attribute(:installment_wanted, false)
      end


      it "has a properly set-up test" do
        expect(ChicagoContact.where(installment_wanted: true).any?).to eq(true)
        expect(ChicagoContact.where(installment_wanted: false).any?).to eq(true)
        expect(Reservation.where.not(price_lock_date: nil).any?).to eq(false)
      end

      it "succeeds" do
        expect(command.call).to be_truthy
      end

      it "returns a value equal to the number of qualifying reservations" do
        expect(command.call).to be_truthy
      end

      it "updates the reservations such that no reservations that qualify for backdated price_lock_dates remain" do
        command.call
        expect(NonPricelockedReservationsWithInstallmentRequests.new.call.any?).to eq(false)
      end
    end

    context "when there is a record that cannot be updated" do
      before do
        contact_one.update_attribute(:installment_wanted, true)
        contact_two.update_attribute(:installment_wanted, true)
        contact_three.update_attribute(:installment_wanted, true)
        contact_four.update_attribute(:installment_wanted, true)

        reservation_three.update_attribute(:state, "INVALID")
      end

      it "has a properly set-up test" do
        expect(Reservation.where(state: "INVALID").any?).to eq(true)
        expect(ChicagoContact.where.not(installment_wanted: true).any?).to eq(false)
        expect(Reservation.where.not(price_lock_date: nil).any?).to eq(false)
      end

      it "returns false" do
        expect(command.call).to be_falsey
      end

      it "Does not update the price lock date of a record with a problem" do
        command.call
        prob = Reservation.where(price_lock_date: nil, state: "INVALID")
        expect(prob.size).to eql(1)
        expect(prob.first.id).to eql(reservation_three.id)
      end

      it "updates the price lock dates of the valid records" do
        command.call
        no_prob = Reservation.where(price_lock_date: nil).where.not(state: "INVALID")
        expect(no_prob.size).to eql(0)
      end

      it "sets error" do
        command.call
        expect(command.errors.size).to eql(1)
        expect(command.errors).to include(/update/i)
      end

      it "emits standard output about the problem" do
        expect {command.call}.to output(/problem/i).to_stdout
      end
    end
  end
end
