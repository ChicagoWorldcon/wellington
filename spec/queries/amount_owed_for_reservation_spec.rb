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

    context "with direct charges but no cart charges" do
      let(:user) { create(:user) }
      let(:claim) { create(:claim, :with_reservation, user: user) }
      let(:membership) { claim.reservation.membership }
      let(:charge_amount) { Money.new(10_00) }
      let(:reservation) { claim.reservation }

      before do
        create(:charge, user: user, buyable: claim.reservation, amount: charge_amount)
      end

      it "returns the amount owing" do
        expect(amount_owed.format).to eq (membership.price - charge_amount).format
      end

      context "where some direct charges have failed" do
        before do
          create(:charge, user: user, buyable: claim.reservation, amount: charge_amount, state: Charge::STATE_FAILED)
        end

        it "returns the amount owing" do
          expect(amount_owed.format).to eq (membership.price - charge_amount).format
        end
      end
    end

    context "with cart charges but direct charges" do
      let(:fully_paid_one_charge_cart) { create(:cart, :fully_paid_through_single_direct_charge)}
      let(:cart_paid_item )  { fully_paid_one_charge_cart.cart_items[0] }
      let(:reservation) { cart_paid_item.item_reservation}

      it "returns the amount owing" do
        expect(amount_owed.cents).to eq(0)
      end

      context "where all cart charges have failed" do
        let(:failed_c_and_unpaid_r_cart) { create(:cart, :with_failed_charges, :with_unpaid_reservation_items)}
        let(:unpaid_fail_item )  { failed_c_and_unpaid_r_cart.cart_items[0] }
        let(:reservation) {unpaid_fail_item.item_reservation}

        it "returns the amount owing" do
          expect(amount_owed.cents).to eq(unpaid_fail_item.acquirable.price_cents)
        end
      end
    end

    context "with a combination of cart charges and direct charges" do
      context "When the cart's direct charges aren't sufficient to pay for any amounts owing on reservations in the cart" do
        let(:part_pd_thru_combo_cart) { create(:cart, :partially_paid_through_direct_charge_and_paid_item_combo)}
        let(:part_pd_thru_combo_item )  { part_pd_thru_combo_cart.cart_items[0] }
        let(:reservation) {part_pd_thru_combo_item.item_reservation}

        it "returns the amount owing on the reservation, less the reservation's direct charges, but ignoring cart-charges" do
          sum_good_dir_res_charges = reservation.charges.inject(0) {|a, c| a + ( c.successful? ? c.amount_cents : 0 )}
          expect(amount_owed.cents).to eq(part_pd_thru_combo_item.acquirable.price_cents - sum_good_dir_res_charges)
        end
      end

      context "When, in combination, charges for the cart and charges for reservations within it, are enough to pay for the cart's contents" do
        let(:fully_pd_thru_combo_cart) { create(:cart, :fully_paid_through_direct_charge_and_paid_item_combo) }
        let(:unpaid_item_in_combo_cart) { fully_pd_thru_combo_cart.cart_items.select {|i| !i.item_reservation.successful_direct_charges? }.first }
        let(:reservation) { unpaid_item_in_combo_cart.item_reservation }

        it "returns an amount owing of zero" do
          expect(amount_owed.cents).to eq(0)
        end
      end
    end
  end

  describe "#fully_paid_by_cart?" do
    #TODO NOTE: This ideally should have tests of its own, but this is actually pretty thoroughly tested by #amount_owed's spec, above.
    pending
  end
end
