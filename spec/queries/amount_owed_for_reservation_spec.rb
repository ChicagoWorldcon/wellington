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

    context "with cart charges but no direct charges" do
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

    context "when a reservation is being upgraded" do
      let(:supporting_membership) { Membership.find_by(name: :supporting ) || create(:membership, :supporting)}
      let(:attending_membership) { Membership.find_by(name: :adult ) || create(:membership, :adult)}

      context "when the reservation was paid for directly" do
        let(:upgrading_reservation_old_direct) { create(:reservation, :with_upgradable_membership, :with_claim_from_user) }
        let(:upgrading_reservation_new_direct) { create(:reservation, :with_upgradable_membership, :with_claim_from_user, :with_last_fully_paid_membership_logged) }

        context  "when testing" do
          it "uses test reservations that start out with a supporting membership" do
            expect(upgrading_reservation_old_direct.membership.to_s).to eq("Supporting")
            expect(upgrading_reservation_new_direct.membership.to_s).to eq("Supporting")
          end

          it "uses test reservations that start out with last_fully_paid_membership either nil or logged as supporting" do
            expect(upgrading_reservation_old_direct.last_fully_paid_membership).to be_nil
            expect(upgrading_reservation_new_direct.last_fully_paid_membership).to eq(upgrading_reservation_new_direct.membership)
          end

          it "uses test reservations that start out with charges that equal the price of a supporting membership" do
            expect(upgrading_reservation_old_direct.charges.successful.sum(&:amount).to_i).to eql(supporting_membership.price_cents / 100)

            expect(upgrading_reservation_old_direct.charges.successful.sum(&:amount).to_i).to_not eql(attending_membership.price_cents / 100)

            expect(upgrading_reservation_new_direct.charges.successful.sum(&:amount).to_i).to eql(supporting_membership.price_cents / 100)

            expect(upgrading_reservation_new_direct.charges.successful.sum(&:amount).to_i).to_not eql(attending_membership.price_cents / 100)
          end
        end

        context "when there is nothing logged under last_fully_paid_membership" do
          context "when the original (supporting) membership is still the active membership" do
            let(:reservation) { upgrading_reservation_old_direct }

            it "returns an amount owing of zero" do
              expect(amount_owed.cents).to eq(0)
            end
          end

          context "when the active membership is changed to 'Adult'" do
            before do
              SetMembership.new(upgrading_reservation_old_direct, to: attending_membership).call
              upgrading_reservation_old_direct.reload
            end

            let(:reservation) { upgrading_reservation_old_direct }

            it "returns an amount owing equal to the difference in price between a supporting membership and an attending membership" do
              expect(amount_owed.cents).to eq(attending_membership.price_cents - supporting_membership.price_cents)
            end
          end
        end

        context "when last_fully_paid_membership has a value" do
          context "when the original (supporting) membership is still the active membership" do
            let(:reservation) { upgrading_reservation_new_direct }

            it "returns an amount owing of zero" do
              expect(amount_owed.cents).to eq(0)
            end
          end

          context "when the active membership is changed to 'Adult'" do
            before do
              SetMembership.new(upgrading_reservation_new_direct, to: attending_membership).call
              upgrading_reservation_new_direct.reload
            end

            let(:reservation) { upgrading_reservation_new_direct }

            it "returns an amount owing equal to the difference in price between a supporting membership and an attending membership" do
              #binding.pry
              expect(amount_owed.cents).to eq(attending_membership.price_cents - supporting_membership.price_cents)
            end
          end
        end
      end

      context "when the original membership was paid for by cart" do
        let(:reservation_cart ) { create(:cart, :supporting_res_items_fully_paid_through_single_direct_charge)}
        let(:upgrading_reservation_from_cart) {reservation_cart.cart_items[0].item_reservation}

        context "when the original (supporting) membership is still the active membership" do
          let(:reservation) { upgrading_reservation_from_cart }

          it "returns an amount owing of zero" do
            expect(amount_owed.cents).to eq(0)
          end
        end

        context "when the active membership is changed to 'Adult'" do
          before do
            SetMembership.new(upgrading_reservation_from_cart, to: attending_membership).call
            upgrading_reservation_from_cart.reload
          end

          let(:reservation) { upgrading_reservation_from_cart }

          it "Xreturns an amount owing equal to the difference in price between a supporting membership and an attending membership" do
            expect(amount_owed.cents).to eq(attending_membership.price_cents - supporting_membership.price_cents)
          end
        end
      end
    end
  end
end
