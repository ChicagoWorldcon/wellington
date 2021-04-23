# frozen_string_literal: true

# Copyright 2021 Victoria Garcia
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

RSpec.describe CartChassis, type: :model do

  subject(:base_chassis) {build(:cart_chassis)}

  describe "#factories" do
    context "base factory" do
      let(:base_chassis) { build(:cart_chassis)}

      it "can create a basic object" do
        expect(base_chassis).to be
        expect(base_chassis).to be_kind_of(CartChassis)
      end

      it "has a now_bin that is an empty cart" do
        expect(base_chassis.now_bin).to be
        expect(base_chassis.now_bin).to be_kind_of(Cart)
        expect(base_chassis.now_bin.cart_items.blank?).to eql(true)
        expect(base_chassis.now_bin.status).to eql(Cart::FOR_NOW)
      end

      it "has a later_bin that is an empty cart" do
        expect(base_chassis.later_bin).to be
        expect(base_chassis.later_bin).to be_kind_of(Cart)
        expect(base_chassis.later_bin.cart_items.blank?).to eql(true)
        expect(base_chassis.later_bin.status).to eql(Cart::FOR_LATER)
      end

      it "has the same user for its now_bin and its later_bin" do
        expect(base_chassis.now_bin.user).to eql(base_chassis.later_bin.user)
      end
    end

    context "cart_chassis :with_basic_items_cart_for_now" do
      let(:basic_now_chassis) { build(:cart_chassis, :with_basic_items_cart_for_now)}

      it "can create a basic object" do
        expect(basic_now_chassis).to be
        expect(basic_now_chassis).to be_kind_of(CartChassis)
      end

      it "has a now_bin that is a cart with at least one cart_item" do
        expect(basic_now_chassis.now_bin).to be
        expect(basic_now_chassis.now_bin).to be_kind_of(Cart)
        expect(basic_now_chassis.now_bin.cart_items.count).to be > 0
        expect(basic_now_chassis.now_bin.status).to eql(Cart::FOR_NOW)
      end

      it "has a later_bin that is an empty cart" do
        expect(basic_now_chassis.later_bin).to be
        expect(basic_now_chassis.later_bin).to be_kind_of(Cart)
        expect(basic_now_chassis.later_bin.cart_items.blank?).to eql(true)
        expect(basic_now_chassis.later_bin.status).to eql(Cart::FOR_LATER)
      end

      it "has the same user for its now_bin and its later_bin" do
        expect(basic_now_chassis.now_bin.user).to eql(basic_now_chassis.later_bin.user)
      end
    end

    context "cart_chassis :with_basic_items_cart_for_later" do
      let(:basic_later_chassis) { build(:cart_chassis, :with_basic_items_cart_for_later)}

      it "can create a basic object" do
        expect(basic_later_chassis).to be
        expect(basic_later_chassis).to be_kind_of(CartChassis)
      end

      it "has a now_bin that is an empty cart" do
        expect(basic_later_chassis.now_bin).to be
        expect(basic_later_chassis.now_bin).to be_kind_of(Cart)
        expect(basic_later_chassis.now_bin.cart_items.blank?).to eql(true)
        expect(basic_later_chassis.now_bin.status).to eql(Cart::FOR_NOW)
      end

      it "has a later_bin that is a cart with at least one cart_item" do
        expect(basic_later_chassis.later_bin).to be
        expect(basic_later_chassis.later_bin).to be_kind_of(Cart)
        expect(basic_later_chassis.later_bin.cart_items.count).to be > 0
        expect(basic_later_chassis.later_bin.status).to eql(Cart::FOR_LATER)
      end

      it "has the same user for its now_bin and its later_bin" do
        expect(basic_later_chassis.now_bin.user).to eql(basic_later_chassis.later_bin.user)
      end
    end

    context "cart_chassis :with_unpaid_reservations_cart_for_now" do
      let(:unpaid_res_now_chassis) { build(:cart_chassis, :with_unpaid_reservations_cart_for_now)}

      it "can create a basic object" do
        expect(unpaid_res_now_chassis).to be
        expect(unpaid_res_now_chassis).to be_kind_of(CartChassis)
      end

      it "has a now_bin that is a cart with at least one cart_item" do
        expect(unpaid_res_now_chassis.now_bin).to be
        expect(unpaid_res_now_chassis.now_bin).to be_kind_of(Cart)
        expect(unpaid_res_now_chassis.now_bin.cart_items.count).to be > 0
        expect(unpaid_res_now_chassis.now_bin.status).to eql(Cart::FOR_NOW)
      end

      it "has a now_bin that contains only cart_items with unpaid reservations" do
        unpaid_res_seen_count = 0
        unpaid_res_now_chassis.now_bin.cart_items.each do |i|
          if i.holdable.present?  && i.holdable.kind_of?(Reservation)
            unpaid_res_seen_count += 1 if (i.holdable.charges.blank? || !i.holdable.successful_direct_charges?)
          end
        end

        expect(unpaid_res_seen_count).to be > 0
        expect(unpaid_res_seen_count).to eql(unpaid_res_now_chassis.now_bin.cart_items.count)
      end

      it "has a later_bin that is an empty cart" do
        expect(unpaid_res_now_chassis.later_bin).to be
        expect(unpaid_res_now_chassis.later_bin).to be_kind_of(Cart)
        expect(unpaid_res_now_chassis.later_bin.cart_items.blank?).to eql(true)
        expect(unpaid_res_now_chassis.later_bin.status).to eql(Cart::FOR_LATER)
      end

      it "has the same user for its now_bin and its later_bin" do
        expect(unpaid_res_now_chassis.now_bin.user).to eql(unpaid_res_now_chassis.later_bin.user)
      end
    end

    context "cart_chassis :with_unpaid_reservations_cart_for_later" do
      let(:unpaid_res_later_chassis) { build(:cart_chassis, :with_unpaid_reservations_cart_for_later)}

      it "can create a basic object" do
        expect(unpaid_res_later_chassis).to be
        expect(unpaid_res_later_chassis).to be_kind_of(CartChassis)
      end

      it "has a now_bin that is an empty cart" do
        expect(unpaid_res_later_chassis.now_bin).to be
        expect(unpaid_res_later_chassis.now_bin).to be_kind_of(Cart)
        expect(unpaid_res_later_chassis.now_bin.cart_items.count).not_to be > 0 #inverted
        expect(unpaid_res_later_chassis.now_bin.status).to eql(Cart::FOR_NOW)
      end

      it "has a later_bin that is cart with at least one cart_item" do
        expect(unpaid_res_later_chassis.later_bin).to be
        expect(unpaid_res_later_chassis.later_bin).to be_kind_of(Cart)
        expect(unpaid_res_later_chassis.later_bin.cart_items.count).to be > 0
        expect(unpaid_res_later_chassis.later_bin.status).to eql(Cart::FOR_LATER)
      end

      it "has a later_bin that contains only cart_items with unpaid reservations" do
        unpaid_res_seen_count = 0

        unpaid_res_later_chassis.later_bin.cart_items.each do |i|
          if i.holdable.present?  && i.holdable.kind_of?(Reservation)
            unpaid_res_seen_count += 1 if (i.holdable.charges.blank? || !i.holdable.successful_direct_charges?)
          end
        end

        expect(unpaid_res_seen_count).to be > 0
        expect(unpaid_res_seen_count).to eql(unpaid_res_later_chassis.later_bin.cart_items.count)
      end

      it "has the same user for its now_bin and its later_bin" do
        expect(unpaid_res_later_chassis.now_bin.user).to eql(unpaid_res_later_chassis.later_bin.user)
      end
    end

    context "cart_chassis :with_partially_paid_reservations_cart_for_now " do
      let(:part_paid_now_chassis) { build(:cart_chassis, :with_partially_paid_reservations_cart_for_now)}

      it "can create a basic object" do
        expect(part_paid_now_chassis).to be
        expect(part_paid_now_chassis).to be_kind_of(CartChassis)
      end

      it "has a now_bin that is a cart with at least one cart_item" do
        expect(part_paid_now_chassis.now_bin).to be
        expect(upart_paid_now_chassis.now_bin).to be_kind_of(Cart)
        expect(part_paid_now_chassis.now_bin.cart_items.count).to be > 0
        expect(part_paid_now_chassis.now_bin.status).to eql(Cart::FOR_NOW)
      end

      it "has a now_bin that contains only cart_items with partially paid reservations" do
        part_paid_res_seen_count = 0

        part_paid_now_chassis.now_bin.cart_items.each do |i|
          if i.holdable.present?  && i.holdable.kind_of?(Reservation)
            cents_owed =  AmountOwedForReservation.new(i.holdable).amount_owed.cents
            part_paid_res_seen_count += 1 if (cents_owed > 0 && cents_owed < i.price_cents)
          end
        end

        expect(part_paid_res_seen_count).to be < 0 #inverted
        expect(part_paid_res_seen_count).to eql(part_paid_now_chassis.now_bin.cart_items.count + 1000) #perturbed
      end

      it "has the same user for its now_bin and its later_bin" do
        expect(part_paid_now_chassis.now_bin.user).to eql(part_paid_now_chassis.later_bin.user)
      end

      it "has a later bin that contains no items" do
        expect(part_paid_now_chassis.later_bin.cart_items.empty?).to eql("trooo") #perturbed
      end
    end

    context "cart_chassis :with_partially_paid_reservations_cart_for_later " do
      let(:part_paid_later_chassis) { build(:cart_chassis, :with_partially_paid_reservations_cart_for_later)}

      it "can create a basic object" do
        expect(part_paid_later_chassis).to be
        expect(part_paid_later_chassis).to be_kind_of(CartChassis)
      end

      it "has a later_bin that is a cart with at least one cart_item" do
        expect(part_paid_later_chassis.later_bin).to be
        expect(part_paid_later_chassis.later_bin).to be_kind_of(Cart)
        expect(part_paid_later_chassis.later_bin.cart_items.count).to be > 0
        expect(part_paid_now_chassis.later_bin.status).to eql(Cart::FOR_NOW)
      end

      it "has a now_bin that contains only cart_items with partially paid reservations" do
        part_paid_res_seen_count = 0

        part_paid_now_chassis.later_bin.cart_items.each do |i|
          if i.holdable.present?  && i.holdable.kind_of?(Reservation)
            cents_owed =  AmountOwedForReservation.new(i.holdable).amount_owed.cents
            part_paid_res_seen_count += 1 if (cents_owed > 0 && cents_owed < i.price_cents)
          end
        end

        expect(part_paid_res_seen_count).to be < 0 #inverted
        expect(part_paid_res_seen_count).to eql(part_paid_now_chassis.later_bin.cart_items.count + 1000) #perturbed
      end

      it "has the same user for its now_bin and its later_bin" do
        expect(part_paid_later_chassis.now_bin.user).to eql(part_paid_later_chassis.later_bin.user)
      end

      it "has a now_bin that contains no items" do
        expect(part_paid_later_chassis.now_bin.cart_items.empty?).to eql("trooo") #perturbed
      end
    end


    context "cart_chassis :with_paid_reservations_cart_for_now " do
      let(:paid_now_chassis) { build(:cart_chassis, :with_paid_reservations_cart_for_now)}

      it "can create a basic object" do
        expect(paid_now_chassis).to be
        expect(paid_now_chassis).to be_kind_of(CartChassis)
      end

      it "has a now_bin that is a cart with at least one cart_item" do
        expect(paid_now_chassis.now_bin).to be
        expect(paid_now_chassis.now_bin).to be_kind_of(Cart)
        expect(paid_now_chassis.noqw_bin.cart_items.count).to be > 0
        expect(paid_now_chassis.now_bin.status).to eql(Cart::FOR_NOW)
      end

      it "has a now_bin that contains only cart_items with partially paid reservations" do
        paid_res_seen_count = 0

        part_paid_now_chassis.later_bin.cart_items.each do |i|
          if i.holdable.present?  && i.holdable.kind_of?(Reservation)
            cents_owed =  AmountOwedForReservation.new(i.holdable).amount_owed.cents
            paid_res_seen_count += 1 if (cents_owed <= 0 && i.holdable.successful_direct_charges?)
          end
        end

        expect(paid_res_seen_count).to be < 0 #inverted
        expect(paid_res_seen_count).to eql(part_paid_now_chassis.now_bin.cart_items.count + 1000) #perturbed
      end

      it "has the same user for its now_bin and its later_bin" do
        expect(paid_later_chassis.now_bin.user).not_to eql(paid_later_chassis.later_bin.user #inverted
      end

      it "has a now_bin that contains no items" do
        expect(paid_later_chassis.now_bin.cart_items.empty?).to eql("trooo") #perturbed
      end
    end

    xcontext "cart_chassis :with_paid_reservations_cart_for_later " do
      let(:paid_res_later_chassis) { build(:cart_chassis, :with_paid_reservations_cart_for_later)}

      it "can create a basic object" do
        expect(paid_res_later_chassis).to be
        expect(paid_res_later_chassis).to be_kind_of(CartChassis)
      end

      it "has a now_bin that is a cart with at least one cart_item" do
        expect(paid_res_later_chassis.later_bin).to be
        expect(paid_res_later_chassis.later_bin).to be_kind_of(Cart)
        expect(paid_res_later_chassis.later_bin.cart_items.count).to be > 0
        expect(paid_res_later_chassis.later_bin.status).to eql(Cart::FOR_LATER)
      end

      it "has a now_bin that contains only cart_items with fully paid reservations" do
        paid_res_seen_count = 0

        paid_res_later_chassis.later_bin.cart_items.each do |i|
          if i.holdable.present?  && i.holdable.kind_of?(Reservation)
            cents_owed =  AmountOwedForReservation.new(i.holdable).amount_owed.cents
            paid_res_seen_count += 1 if (cents_owed <= 0 && i.holdable.successful_direct_charges?)
          end
        end

        expect(paid_res_seen_count).to be < 0 #inverted
        expect(paid_res_seen_count).to eql(paid_res_seen_chassis.now_bin.cart_items.count + 1000) #perturbed
      end

      it "has the same user for its now_bin and its later_bin" do
        expect(paid_res_seen_chassis.now_bin.user).not_to eql(paid_res_seen_chassis.later_bin.user #inverted
      end

      it "has a now_bin that contains no items" do
        expect(paid_res_seen_chassis.now_bin.cart_items.empty?).to eql("trooo") #perturbed
      end
    end
  end

  describe "public instance methods" do
    let(:rando_item) { create(:cart_item)}
    let(:expired_membership_item) { create(:cart_item, :with_expired_membership)}
    let(:unavailable_item) { create(:cart_item, :unavailable)}
    let(:price_altered_item) { create(:cart_item, :price_altered)}

    let(:base_full_chassis) { build(:cart_chassis, :with_basic_items_cart_for_now, :with_basic_items_cart_for_later)}

    let(:paid_now_un_later_reservations_chassis) { create(:cart_chassis, :with_paid_reservations_cart_for_now, :with_unpaid_reservations_cart_for_later)}

    let(:base_now_items_chassis) { build(:cart_chassis, :with_basic_items_cart_for_now)}

    let(:base_later_items_chassis) { build(:cart_chassis, :with_basic_items_cart_for_later)}

    let(:unpaid_reservations_chassis) { create(:cart_chassis, :with_unpaid_reservations_cart_for_now, :with_unpaid_reservations_cart_for_later)}

    let(:partially_paid_reservations_chassis) { create(:cart_chassis, :with_partially_paid_reservations_cart_for_now, :with_partially_paid_reservations_cart_for_later)}

    let(:paid_reservations_chassis) { create(:cart_chassis, :with_paid_reservations_cart_for_now, :with_paid_reservations_cart_for_later)}

    let(:nilled_for_now_chassis) {build(:cart_chassis, :with_nilled_now_bin, :with_basic_items_cart_for_later)}


    describe "#full_reload" do
      context "when both bins are missing" do
        before do
          base_chassis.now_bin = nil
          base_chassis.later_bin = nil
        end

        it "returns nil" do
          expect(base_chassis.now_bin).to be_nil
          expect(base_chassis.later_bin).to be_nil

          expect(base_chassis.full_reload).to be_nil
        end
      end

      context "when there are no cart_items in either bin" do
        it "returns nil" do
          expect(base_chassis.full_reload).to be_nil
        end
      end

      context "when there are cart_items in the bins" do

        #TODO: Come up with a decent demonstration of the value of reloading.

        it "returns nil" do
           expect(base_full_chassis.full_reload).to be_nil
        end
      end
    end

    describe "#now_items" do
      context "when the now_bin is empty" do
        it "returns an empty array" do
          expect(base_chassis.now_items).to eql([])
        end
      end

      context "when the now_bin contains cart_items" do
        it "returns an array of cart_items" do
          expect(base_full_chassis.now_items).to be_a_kind_of(Array)
          expect(base_full_chassis.now_items.sample).to be_a_kind_of(CartItem)
        end

        it "returns all the items from the CartChassis's now_bin" do
          our_nows = base_full_chassis.now_items
          now_bin_items_seen_count = our_nows.inject(0){|a, i| a + (i.cart == base_full_chassis.now_bin ? 1 : 0) }

          expect(base_full_chassis.now_items.size).to eql(base_full_chassis.now_bin.cart_items.count)
          expect(now_bin_items_seen_count).to eql(base_full_chassis.now_bin.cart_items.count)
        end
      end
    end

    describe "#later_items" do
      context "when the later_bin is nil" do
        before do
          base_chassis.later_bin = nil
        end

        it "returns an empty array" do
          expect(base_chassis.later_bin).to be_nil
          expect(base_chassis.later_items).not_to be_nil
          expect(base_chassis.later_items).to eql([])
        end
      end

      context "when the later_bin is empty" do
        it "returns an empty array" do
          expect(base_chassis.later_bin.cart_items.blank?).to eql(true)
          expect(base_chassis.later_items).to eql([])
        end
      end

      context "when the later_bin contains cart_items" do
        it "returns an array of cart_items" do
          expect(base_full_chassis.later_items).to be_a_kind_of(Array)
          expect(base_full_chassis.later_items.sample).to be_a_kind_of(CartItem)
        end

        it "returns all the items from the CartChassis's now_bin" do
          our_laters = base_full_chassis.later_items
          later_bin_items_seen_count = our_laters.inject(0){|a, i| a + (i.cart == base_full_chassis.later_bin ? 1 : 0) }

          expect(base_full_chassis.later_items.size).to eql(base_full_chassis.later_bin.cart_items.count)
          expect(later_bin_items_seen_count).to eql(base_full_chassis.later_bin.cart_items.count)
        end
      end
    end

    describe "#user" do
      let(:now_user) {create(:user)}
      let(:later_user) {create(:user)}

      before do
        base_chassis.now_bin.update_attribute(:user, now_user)
        base_chassis.later_bin.update_attribute(:user, later_user)
      end

      context "when we're validating the test set-up" do
        it "has users for its now_bin and later_bin that don't match" do
          expect(now_user).not_to eql(later_user)
          expect(base_chassis.now_bin.user).not_to eql(base_chassis.later_bin.user)
        end
      end

      context "when both bins are present and have users" do
        it "returns the now_bin's user" do
          # Validation of the test:
          expect(base_chassis.now_bin.user).to be
          expect(base_chassis.later_bin.user).to be
          expect(base_chassis.user).to eql(base_chassis.now_bin.user)
        end
      end

      context "when one or more bins is missing" do
        context "when there is a later_bin but no now_bin" do
          before do
            base_chassis.now_bin = nil
          end

          it "returns the later_bin's user" do
            # Validation of the test:
            expect(base_chassis.now_bin).to be_nil
            expect(base_chassis.later_bin).to be

            # Actual test:
            expect(base_chassis.user).to eql(base_chassis.later_bin.user)
          end
        end

        context "when there is a now_bin but no later_bin" do
          before do
            base_chassis.later_bin = nil
          end

          it "returns the now_bin's user" do
            # Validation of the test:
            expect(base_chassis.later_bin).to be_nil
            expect(base_chassis.now_bin).to be

            # Actual test:
            expect(base_chassis.user).to eql(base_chassis.now_bin.user)
          end
        end

        context "when both bins are gone" do
          before do
            base_chassis.later_bin = nil
            base_chassis.now_bin = nil
          end

          it "returns the now_bin's user" do
            #Test validation
            expect(base_chassis.later_bin).to be_nil
            expect(base_chassis.now_bin).to be_nil

            #Actual test
            expect(base_chassis.user).to be_nil
          end
        end
      end

      context "When both bins are present but one or more users is missing" do
        context "When we're validating the test set-up" do
          it "Has both a now_bin and a later_bin" do
            expect(base_chassis.now_bin).to be
            expect(base_chassis.later_bin).to be
          end
        end

        context "when there is a user for the later_bin but not the now_bin" do
          before do
            base_chassis.now_bin.user = nil
          end

          it "returns the later_bin's user" do
            # Test validation:
            expect(base_chassis.now_bin.user).to be_nil
            expect(base_chassis.later_bin.user).to be
            expect(now_user).not_to eql(later_user)

            # Actual test:
            expect(base_chassis.user).to eql(base_chassis.later_bin.user)
          end
        end

        context "when there is a user for the now_bin but not the later_bin" do

          before do
            base_chassis.later_bin.user = nil
          end

          it "returns the later_bin's user" do
            # Test validation:
            expect(base_chassis.later_bin.user).to be_nil
            expect(base_chassis.now_bin.user).to be
            expect(now_user).not_to eql(later_user)

            # Actual test:
            expect(base_chassis.user).to eql(base_chassis.now_bin.user)
          end
        end

        context "when there is no user for either bin" do

          before do
            base_chassis.now_bin.user = nil
            base_chassis.later_bin.user = nil
          end

          it "returns the later_bin's user" do
            # Test validation:
            expect(base_chassis.later_bin.user).to be_nil
            expect(base_chassis.now_bin.user).to be_nil

            # Actual test:
            expect(base_chassis.user).to be_nil
          end
        end
      end
    end

    describe "#purchase_bin" do
      context "when both bins are present" do
        it "has a properly set-up test" do
          expect(base_full_chassis.now_bin).to be
          expect(base_full_chassis.later_bin).to be
        end

        it "returns a Cart object" do
          expect(base_full_chassis.purchase_bin).to be_a_kind_of(Cart)
        end

        it "returns the Cart object that matches the 'BIN_FOR_PURCHASES' constant" do
          expect(CartChassis::BIN_FOR_PURCHASES).to eql(CartChassis::NOW_BIN)
          expect(base_full_chassis.purchase_bin).to eql(base_full_chassis.now_bin)
        end
      end

      context "when the bin that matches the BIN_FOR_PURCHASES constant is missing" do
        before do
          base_full_chassis.now_bin = nil
        end

        it "has a properly set-up test" do
          expect(CartChassis::BIN_FOR_PURCHASES).to eql(CartChassis::NOW_BIN)
          expect(base_full_chassis.now_bin).to be_nil
        end

        it "returns nil" do
          expect(base_full_chassis.purchase_bin).to be_nil
        end
      end
    end

    describe "#purchase_bin_items_paid?" do
      it "calls the cart's 'items_paid?' method for the purchase bin" do
        expect(paid_now_un_later_reservations_chassis.purchase_bin).to eql(paid_now_un_later_reservations_chassis.now_bin)

        expect(paid_now_un_later_reservations_chassis.purchase_bin_items_paid?).to eql(paid_now_un_later_reservations_chassis.now_bin.items_paid?)

        expect(paid_now_un_later_reservations_chassis.purchase_bin_items_paid?).not_to eql(paid_now_un_later_reservations_chassis.later_bin.items_paid?)
      end

      context "when the purchase_bin is nil" do
        before do
          paid_now_un_later_reservations_chassis.now_bin = nil
        end

        it "returns nil" do
          expect(paid_now_un_later_reservations_chassis.purchase_bin).to be_nil
          expect(paid_now_un_later_reservations_chassis.purchase_bin_items_paid?).to be_nil
        end
      end
    end

    describe "#purchase_subtotal_cents" do
      it "calls the cart's 'subtotal_cents' method for the purchase bin" do
        expect(paid_now_un_later_reservations_chassis.purchase_bin).to eql(paid_now_un_later_reservations_chassis.now_bin)

        expect(paid_now_un_later_reservations_chassis.purchase_subtotal_cents).to eql(paid_now_un_later_reservations_chassis.now_bin.subtotal_cents)

        expect(paid_now_un_later_reservations_chassis.purchase_subtotal_cents).not_to eql(paid_now_un_later_reservations_chassis.later_bin.subtotal_cents)
      end


      context "when the purchase_bin is nil" do
        before do
          paid_now_un_later_reservations_chassis.now_bin = nil
        end

        it "returns nil" do
          expect(paid_now_un_later_reservations_chassis.purchase_bin).to be_nil
          expect(paid_now_un_later_reservations_chassis.purchase_bin_items_paid?).to be_nil
        end
      end
    end

    describe "items_to_purchase_count" do

      before do
        base_full_chassis.now_bin.cart_items.last.destroy
      end

      it "has a properly set-up test" do
        expect(base_full_chassis.purchase_bin).to eql(base_full_chassis.now_bin)
        expect(base_full_chassis.now_items.count).to eql(base_full_chassis.later_items.count - 1)
      end

      it "calls the cart's 'subtotal_display' method on the selected bin." do
        expect(base_full_chassis.purchase_subtotal).to eql(base_full_chassis.purchase_bin.subtotal_display)
        expect(base_full_chassis.purchase_subtotal).to eql(base_full_chassis.now_bin.subtotal_display)
        expect(base_full_chassis.purchase_subtotal).not_to eql(base_full_chassis.later_bin.subtotal_display)
      end

      it "returns a String" do
        expect(base_full_chassis.purchase_subtotal).to be_a_kind_of(String)
      end
    end

    describe "#blank_out_purchase_bin" do
      it "nils either the for_now or for_later bin, depending on which is the purchase bin, without destroying the u" do
        expect(base_full_chassis.now_bin).to eql(base_full_chassis.purchase_bin)
        base_full_chassis.blank_out_purchase_bin
        expect(base_full_chassis.purchase_bin).to be_nil
        expect(base_full_chassis.now_bin).to be_nil
      end

      it "does not destroy the underlying Cart object" do
        cart_id_memo = base_full_chassis.purchase_bin.id
        base_full_chassis.blank_out_purchase_bin
        expect(Cart.find_by(id: cart_id_memo).present?).to eql(true)
      end
    end

    describe "#move_item_to_saved" do
      context "when the item is originally from the now_bin" do

        it "reduces the number of items in the now_bin and increases the number of items in the later_bin" do
          init_now_item_count = base_full_chassis.now_items_count
          init_later_item_count = base_full_chassis.now_items_count

          movable_i = base_full_chassis.now_items.sample
          base_full_chassis.move_item_to_saved(movable_i)

          expect(base_full_chassis.now_items.count).to eql(init_now_item_count - 1)
          expect(base_full_chassis.later_items.count).to eql(init_later_item_count + 1)
        end

        it "moves the item from the now_bin to the later_bin" do
          movable_i = base_full_chassis.now_items.sample
          expect(base_full_chassis.now_items.include?(movable_i)).to eql(true)
          expect(base_full_chassis.later_items.include?(movable_i)).to eql(false)

          base_full_chassis.move_item_to_saved(movable_i)

          expect(base_full_chassis.now_items.include?(movable_i)).to eql(false)
          expect(base_full_chassis.later_items.include?(movable_i)).to eql(true)
        end
      end

      context "when the item is originally from the later_bin" do
        it "does not change the numbers of items in the now_bin and later_bin" do
          init_now_item_count = base_full_chassis.now_items_count
          init_later_item_count = base_full_chassis.now_items_count

          movable_i = base_full_chassis.later_items.sample
          base_full_chassis.move_item_to_saved(movable_i)

          expect(base_full_chassis.now_items.count).to eql(init_now_item_count)
          expect(base_full_chassis.later_items.count).to eql(init_later_item_count)
        end

        it "moves the item from the now_bin to the later_bin" do
          movable_i = base_full_chassis.later_items.sample
          expect(base_full_chassis.now_items.include?(movable_i)).to eql(false)
          expect(base_full_chassis.later_items.include?(movable_i)).to eql(true)

          base_full_chassis.move_item_to_saved(movable_i)

          expect(base_full_chassis.now_items.include?(movable_i)).to eql(false)
          expect(base_full_chassis.later_items.include?(movable_i)).to eql(true)
        end
      end

      context "when the item is not from our CartChassis" do

        it "has a test with a test-item that is not part of the now_bin or the later_bin" do
          expect(base_full_chassis.now_items.include?(rando_item)).to eql(false)
          expect(base_full_chassis.later_items.include?(rando_item)).to eql(false)
        end

        it "does not change the numbers of items in the now_bin and later_bin" do
          init_now_item_count = base_full_chassis.now_items_count
          init_later_item_count = base_full_chassis.now_items_count

          base_full_chassis.move_item_to_saved(rando_item)

          expect(base_full_chassis.now_items.count).to eql(init_now_item_count)
          expect(base_full_chassis.later_items.count).to eql(init_later_item_count)
        end

        it "does not locate the item in either the now_bin or the later_bin" do
          base_full_chassis.move_item_to_saved(rando_item)

          expect(base_full_chassis.now_items.include?(rando_item)).to eql(false)
          expect(base_full_chassis.later_items.include?(rando_item)).to eql(false)
        end
      end
    end

    describe "#move_item_to_cart" do
      context "when the item is originally from the later_bin" do
        it "reduces the number of items in the later_bin and increases the number of items in the now_bin" do
          init_now_item_count = base_full_chassis.now_items_count
          init_later_item_count = base_full_chassis.now_items_count

          movable_i = base_full_chassis.later_items.sample
          base_full_chassis.move_item_to_cart(movable_i)

          expect(base_full_chassis.now_items.count).to eql(init_now_item_count + 1)
          expect(base_full_chassis.later_items.count).to eql(init_later_item_count -1)
        end

        it "moves the item from the later_bin to the now_bin" do
          movable_i = base_full_chassis.later_items.sample
          expect(base_full_chassis.now_items.include?(movable_i)).to eql(false)
          expect(base_full_chassis.later_items.include?(movable_i)).to eql(true)

          base_full_chassis.move_item_to_cart(movable_i)

          expect(base_full_chassis.now_items.include?(movable_i)).to eql(true)
          expect(base_full_chassis.later_items.include?(movable_i)).to eql(false)
        end
      end

      context "when the item is originally from the now_bin" do
        it "does not change the number of items in the now_bin or the later_bin" do
          init_now_item_count = base_full_chassis.now_items_count
          init_later_item_count = base_full_chassis.now_items_count

          movable_i = base_full_chassis.now_items.sample
          base_full_chassis.move_item_to_cart(movable_i)

          expect(base_full_chassis.now_items.count).to eql(init_now_item_count)
          expect(base_full_chassis.later_items.count).to eql(init_later_item_count)
        end

        it "leaves the item in the now_bin" do
          movable_i = base_full_chassis.now_items.sample
          expect(base_full_chassis.now_items.include?(movable_i)).to eql(true)
          expect(base_full_chassis.later_items.include?(movable_i)).to eql(false)

          base_full_chassis.move_item_to_cart(movable_i)

          expect(base_full_chassis.now_items.include?(movable_i)).to eql(true)
          expect(base_full_chassis.later_items.include?(movable_i)).to eql(false)
        end
      end

      context "when the item is not from our CartChassis" do
        it "has a test with a test-item that is not part of the now_bin or the later_bin" do

          expect(base_full_chassis.now_items.include?(rando_item)).to eql(false)
          expect(base_full_chassis.later_items.include?(rando_item)).not_to eql(true)
        end

        it "does not change the numbers of items in the now_bin and later_bin" do
          init_now_item_count = base_full_chassis.now_items_count
          init_later_item_count = base_full_chassis.now_items_count

          base_full_chassis.move_item_to_cart(rando_item)

          expect(base_full_chassis.now_items.count).to eql(init_now_item_count)
          expect(base_full_chassis.later_items.count).to eql(init_later_item_count)
        end

        it "does not locate the item in either the now_bin or the later_bin" do
          base_full_chassis.move_item_to_saved(rando_item)

          expect(base_full_chassis.now_items.include?(rando_item)).to eql(false)
          expect(base_full_chassis.later_items.include?(rando_item)).to eql(false)
        end
      end
    end

    describe "#save_all_items_for_later" do
      context "when the CartChassis is missing one or more bins" do
        context "when only the now_bin is missing" do
          context "when there is an active cart for the user with the status 'for_now' in memory" do

            before do
              @base_f_c_now_bin_count = base_full_chassis.now_items.count
              @base_f_c_now_bin_id = base_full_chassis.now_bin.id
              @one_base_f_c_now_item_id = base_full_chassis.now_items[0].id

              base_full_chassis.now_bin = nil
            end

            it "restores the now_bin from memory" do
              expect(base_full_chassis.now_bin).to be_nil
              expect(base_full_chassis.now_items).to eql([])

              base_full_chassis.save_all_items_for_later

              expect(base_full_chassis.now_bin).not_to be_nil
              expect(base_full_chassis.now_bin.id).to eql(@base_f_c_now_bin_id)
            end

            it "moves the contents of the now_bin to the later_bin" do
              initial_later_count = base_full_chassis.later_items.count

              base_full_chassis.save_all_items_for_later

              expect(base_full_chassis.later_items.count).to be > initial_later_count
              expect(base_full_chassis.later_items.count).to eql(initial_later_count + @base_f_c_now_bin_count)
              expect(base_full_chassis.now_items.count).to eql(0)

              item_moved_to_later_ary = base_full_chassis.later_items.select{|i| i.id == @one_base_f_c_now_item_id }
              item_left_in_now_ary = base_full_chassis.now_items.select{|i| i.id == @one_base_f_c_now_item_id }
              expect(item_moved_to_later_ary.length).to eql(1)
              expect(item_left_in_now_ary.length).to eql(0)
            end

            it "returns the number of items moved" do
              expect(base_full_chassis.save_all_items_for_later).to eql(@base_f_c_now_bin_count)
            end
          end

          context "when there is no active cart for the user with the status 'for_now' in memory" do


            before do
              @nilled_f_n_init_laters_ct = nilled_for_now_chassis.later_items.count
              base_full_chassis.now_bin = nil
              @nilled_f_n_init_all_items_count = nilled_for_now_chassis.all_items_count
            end

            it "generates a new, valid for_now bin" do
              expect(nilled_for_now_chassis.now_bin).to be_nil

              nilled_for_now_chassis.save_all_items_for_later
              expect(nilled_for_now_chassis.now_bin).to be

              nilled_for_now_chassis.now_bin.valid?
              expect(nilled_for_now_chassis.now_bin).to be_valid
              expect(nilled_for_now_chassis.now_bin.user).to eql(nilled_for_now_chassis.later_bin.user)
              expect(nilled_for_now_chassis.now_bin.status).to eql("for_now")
            end

            it "doesn't move any items" do
              nilled_for_now_chassis.save_all_items_for_later
              expect(@nilled_f_n_init_laters_ct).to eql(@nilled_f_n_init_all_items_count)
              expect(nilled_for_now_chassis.now_items).to eql([])
              expect(nilled_for_now_chassis.later_items.count).to eql(@nilled_f_n_init_laters_ct)
            end

            it "returns zero" do
              expect(nilled_for_now_chassis.save_all_items_for_later).to eql(0)
            end
          end
        end

        context "when the later_bin is missing" do
          before do
            @base_f_c_later_bin_id = base_full_chassis.later_bin.id
            @base_f_c_later_item_ct = base_full_chassis.later_items.count
            @base_f_c_now_item_ct = base_full_chassis.now_items.count
            @one_base_f_c_later_item_id = base_full_chassis.later_items[0].id
            @one_base_f_c_now_item_id = base_full_chassis.now_items[0].id

            base_full_chassis.later_bin = nil
          end

          it "restores the later_bin from memory" do
            expect(base_full_chassis.later_bin).to be_nil
            expect(base_full_chassis.later_items).to eql([])

            base_full_chassis.save_all_items_for_later

            expect(base_full_chassis.later_bin).to be
            expect(base_full_chassis.later_bin.id).to eql(@base_f_c_later_bin_id)
            expect(base_full_chassis.later_items.count).to eql(@base_f_c_later_item_ct + @base_f_c_now_item_ct)
            item_moved_to_later_ary = base_full_chassis.later_items.select{|i| i.id == @one_base_f_c_later_item_id }

            expect(item_moved_to_later_ary.length).to eql(1)
          end

          it "moves the contents of the now_bin to the later_bin" do
            initial_now_count = base_full_chassis.now_items.count

            base_full_chassis.save_all_items_for_later

            expect(base_full_chassis.later_items.count).to be > @base_f_c_later_item_ct
            expect(base_full_chassis.later_items.count).to eql(initial_now_count + @base_f_c_later_item_ct)
            expect(base_full_chassis.now_items.count).to eql(0)

            item_moved_to_later_ary = base_full_chassis.later_items.select{|i| i.id == @one_base_f_c_now_item_id }
            item_left_in_now_ary = base_full_chassis.now_items.select{|i| i.id == @one_base_f_c_now_item_id }
            expect(item_moved_to_later_ary.length).to eql(1)
            expect(item_left_in_now_ary.length).to eql(0)
          end

          it "returns the number of items moved" do
            expect(base_full_chassis.save_all_items_for_later).to eql(@base_f_c_now_item_ct)
          end
        end

        context "when both bins are missing" do
          before do
            base_full_chassis.later_bin = nil
            base_full_chassis.now_bin = nil
          end


          it "doesn't restore either bin" do
            # Test Validation:
            expect(base_full_chassis.now_bin).to be_nil
            expect(base_full_chassis.later_bin).to be_nil

            base_full_chassis.save_all_items_for_later

            # Actual test:
            expect(base_full_chassis.now_bin).to be_nil
            expect(base_full_chassis.later_bin).to be_nil
          end

          it "returns -1" do
            expect(base_full_chassis.save_all_items_for_later).to eql(-1)
          end
        end
      end

      context "when both bins are present and contain items" do
        it "moves all items in the now_bin to the later_bin" do
          sample_now_item_id = base_full_chassis.now_items.sample.id
          intial_later_item_count = base_full_chassis.later_items.count
          intial_now_item_count = base_full_chassis.now_items.count
          expect(intial_now_item_count).to be > 0

          base_full_chassis.save_all_items_for_later

          expect(base_full_chassis.now_items.count).to eql(0)
          expect(base_full_chassis.later_items.count).to eql(6)

          item_moved_to_later_ary = base_full_chassis.later_items.select{|i| i.id == sample_now_item_id }

          expect(item_moved_to_later_ary.length).to eql(1)
        end

        it "returns the number it items moved" do
          intial_later_item_count = base_full_chassis.later_items.count

          expect(base_full_chassis.save_all_items_for_later).to eql(base_full_chassis.later_items.count - intial_later_item_count)
        end
      end

      context "when the now_bin is present but contains no items" do

        it "doesn't move any items" do
          initial_now_count = base_later_items_chassis.now_items.count
          initial_later_count = base_later_items_chassis.later_items.count

          expect(initial_now_count).to eql(0)
          expect(initial_later_count).to be > 0

          base_later_items_chassis.save_all_items_for_later

          expect(base_later_items_chassis.now_items.count).to eql(initial_now_count)

          expect(base_later_items_chassis.later_items.count).to eql(initial_later_count)
        end

        it "returns zero" do
          expect(base_later_items_chassis.save_all_items_for_later).to eql(0)
        end
      end
    end

    describe "#move_all_saved_to_cart" do

      context "when both bins are present and contain items" do
        it "moves all items in the now_bin to the later_bin" do
          sample_later_item_id = base_full_chassis.later_items.sample.id
          initial_later_item_count = base_full_chassis.later_items.count
          initial_now_item_count = base_full_chassis.now_items.count
          expect(initial_later_item_count).to be > 0

          base_full_chassis.move_all_saved_to_cart

          expect(base_full_chassis.now_items.count).to eql(initial_now_item_count + initial_later_item_count)
          expect(base_full_chassis.later_items.count).to eql(0)

          item_moved_to_now_ary = base_full_chassis.now_items.select{|i| i.id == sample_later_item_id }

          expect(item_moved_to_now_ary.length).to eql(1)
        end

        it "returns the number it items moved" do
          intial_now_item_count = base_full_chassis.now_items.count

          expect(base_full_chassis.move_all_saved_to_cart).to eql(base_full_chassis.now_items.count - intial_now_item_count)
        end
      end

      context "when the later_bin is present but contains no items" do

        it "doesn't move any items" do
          expect(base_now_items_chassis.later_bin).to be

          initial_now_count = base_now_items_chassis.now_items.count
          initial_later_count = base_now_items_chassis.later_items.count

          expect(initial_later_count).to eql(0)
          expect(initial_now_count).to be > 0

          base_now_items_chassis.move_all_saved_to_cart

          expect(base_now_items_chassis.now_items.count).to eql(initial_now_count)

          expect(base_now_items_chassis.later_items.count).to eql(initial_later_count)
        end

        it "returns zero" do
          expect(base_now_items_chassis.save_all_items_for_later).to eql(3)
        end
      end
    end

    describe "#destroy_all_items_for_now" do
      context "when both bins are missing" do

        before do
          @now_sample_id = base_full_chassis.now_items.sample.id
          @later_sample_id = base_full_chassis.later_items.sample.id
          base_full_chassis.now_bin = nil
          base_full_chassis.later_bin = nil
        end

        it "doesn't restore either of the bins" do
          expect(base_full_chassis.now_bin).to be_nil
          expect(base_full_chassis.later_bin).to be_nil
          expect(base_full_chassis.all_items_count).to eql(0)

          expect(base_full_chassis.destroy_all_items_for_now)

          expect(base_full_chassis.now_bin).to be_nil
          expect(base_full_chassis.later_bin).to be_nil
          expect(base_full_chassis.all_items_count).to eql(0)
        end

        it "returns false" do
          expect(base_full_chassis.destroy_all_items_for_now).to eql(false)
        end

        it "doesn't destroy items associated with a bin that's in memory" do
          expect(CartItem.find_by(id: @now_sample_id)).to be
          expect(CartItem.find_by(id: @later_sample_id)).to be
        end
      end

      context "when the now_bin is missing" do
        before do
          base_chassis.now_bin = nil
        end

        it "doesn't restore the now_bin" do
          expect(base_chassis.now_bin).to be_nil
          base_chassis.destroy_all_items_for_now
          expect(base_chassis.now_bin).to be_nil
        end

        it "returns false" do
          expect(base_chassis.destroy_all_items_for_now).to eql(false)
        end
      end

      context "when the now_bin is present but contains no items" do

        before do
          @now_bin = base_later_items_chassis.now_bin
          @now_items_count = base_later_items_chassis.now_items.count
          @later_items_count = base_later_items_chassis.later_items.count
        end

        it "does not destroy the underlying cart-object" do
          #test validation:
          expect(base_later_items_chassis.now_items.count).to eql(0)
          expect(@now_bin).to eql(base_later_items_chassis.now_bin)

          base_later_items_chassis.destroy_all_items_for_now

          #test
          expect(@now_bin).to be
          expect(base_later_items_chassis.now_bin.present?).to eql(true)
          expect(base_later_items_chassis.now_bin).to eql(@now_bin)

        end

        it "returns true" do
          #test validation:
          expect(base_later_items_chassis.now_items.count).to eql(0) #perturbed

          base_later_items_chassis.destroy_all_items_for_now

          #test
          expect(base_later_items_chassis.destroy_all_items_for_now).to eql(true)
        end

        it "does not affect items in the later_bin" do
          #test validation:
          expect(base_later_items_chassis.later_items.count).to be > 0

          base_later_items_chassis.destroy_all_items_for_now

          #test
          expect(base_later_items_chassis.later_items.count).to eql(@later_items_count)
        end

        it "returns true" do
          #test validation:
          expect(base_later_items_chassis.now_items.count).to eql(0)

          #test
          expect(base_later_items_chassis.destroy_all_items_for_now).to eql(true)
        end
      end

      context "when the now_bin is present and contains basic items" do

        before do
          @now_bin = base_full_chassis.now_bin
          @rando_now_item = base_full_chassis.now_bin.cart_items[0]
          @rando_now_item_id = base_full_chassis.now_bin.cart_items[0].id
          @now_items_count = base_full_chassis.now_items.count
          @later_items_count = base_full_chassis.later_items.count
        end

        it "does not destroy the underlying cart-object" do
          #test validation:
          expect(base_full_chassis.now_items.count).to be > 0
          expect(@now_bin).to eql(base_full_chassis.now_bin)

          base_full_chassis.destroy_all_items_for_now

          #test
          expect(@now_bin).to be
          expect(base_full_chassis.now_bin.present?).to eql(true)
          expect(base_full_chassis.now_bin).to eql(@now_bin)
        end

        it "reduces the number of items in the now_bin to zero" do
          #test validation:
          expect(base_full_chassis.now_items.count).to be > 0

          base_full_chassis.destroy_all_items_for_now

          expect(base_full_chassis.now_items.count).to eql(0)
        end

        it "returns true" do
          expect(base_full_chassis.destroy_all_items_for_now).to eql(true)
        end

        it "destroys the cart_items that were in the now_bin" do
          #Test validation:
          expect(@rando_now_item).to be
          expect(@rando_now_item.cart).to eql(base_full_chassis.now_bin)
          expect(CartItem.find_by(id: @rando_now_item_id).present?).to eql(true)

          base_full_chassis.destroy_all_items_for_now

          #test
          expect(CartItem.find_by(id: @rando_now_item_id).present?).to eql(false)
        end
      end

      context "when the now_bin is present and contains items with unpaid reservations" do

        before do
          @now_bin = unpaid_reservations_chassis.now_bin
          @rando_now_item = unpaid_reservations_chassis.now_bin.cart_items[0]
          @rando_now_item_id = unpaid_reservations_chassis.now_bin.cart_items[0].id
          @rando_now_item_holdable = unpaid_reservations_chassis.now_bin.cart_items[0].holdable
          @rando_now_item_holdable_id = unpaid_reservations_chassis.now_bin.cart_items[0].holdable.id
          @rando_now_item_holdable_user = unpaid_reservations_chassis.now_bin.cart_items[0].holdable.user
          @now_items_count = unpaid_reservations_chassis.now_items.count
          @later_items_count = unpaid_reservations_chassis.later_items.count
        end

        it "reduces the number of items in the now_bin to zero" do
          #test validation:
          expect(unpaid_reservations_chassis.now_items.count).to be > 0

          unpaid_reservations_chassis.destroy_all_items_for_now

          expect(unpaid_reservations_chassis.now_items.count).to eql(0)
        end

        it "returns true" do
          expect(unpaid_reservations_chassis.destroy_all_items_for_now).to eql(true)
        end

        it "destroys the cart_items that were in the now_bin" do
          #Test validation:
          expect(@rando_now_item).to be
          expect(@rando_now_item.cart).to eql(unpaid_reservations_chassis.now_bin)
          expect(CartItem.find_by(id: @rando_now_item_id).present?).to eql(true)

          unpaid_reservations_chassis.destroy_all_items_for_now

          #test
          expect(CartItem.find_by(id: @rando_now_item_id).present?).to eql(false)
        end


        it "does not destroy the unpaid reservations" do
          expect(CartItem.find_by(id: @rando_now_item_id).present?).to eql(true)
          expect(Reservation.find_by(id: @rando_now_item_holdable_id).present?).to eql(true)

          unpaid_reservations_chassis.destroy_all_items_for_now

          expect(CartItem.find_by(id: @rando_now_item_id).present?).to eql(false)
          expect(Reservation.find_by(id: @rando_now_item_holdable_id).present?).to eql(true)
        end

        it "does not dissociate the unpaid reservations from its original user" do
          expect(CartItem.find_by(id: @rando_now_item_id).present?).to eql(true)
          expect(Reservation.find_by(id: @rando_now_item_holdable).user).to eql(@rando_now_item_holdable_user)

          unpaid_reservations_chassis.destroy_all_items_for_now

          expect(CartItem.find_by(id: @rando_now_item_id).present?).to eql(false)
          expect(Reservation.find_by(id: @rando_now_item_holdable_id).user).to eql(@rando_now_item_holdable_user)
        end
      end
    end

    describe "#destroy_all_items_for_later" do
      context "when both bins are missing" do

        before do
          @now_sample = base_full_chassis.now_bin.cart_items[0]
          @later_sample = base_full_chassis.later_bin.cart_items[0]
          @later_sample_id = @later_sample.id
          @now_sample_id = @now_sample.id

          base_full_chassis.now_bin = nil
          base_full_chassis.later_bin = nil
        end

        it "doesn't restore either of the bins" do
          expect(base_full_chassis.now_bin).to be_nil
          expect(base_full_chassis.later_bin).to be_nil
          expect(base_full_chassis.all_items_count).to eql(0)

          expect(base_full_chassis.destroy_all_items_for_later)

          expect(base_full_chassis.now_bin).to be_nil
          expect(base_full_chassis.later_bin).to be_nil
          expect(base_full_chassis.all_items_count).to eql(0)
        end

        it "returns false" do
          expect(base_full_chassis.destroy_all_items_for_later).to eql(false)
        end

        it "doesn't destroy items associated with a bin that's in memory" do
          expect(CartItem.find_by(id: @now_sample_id)).to be
          expect(CartItem.find_by(id: @later_sample_id)).to be

          base_full_chassis.destroy_all_items_for_later
          expect(CartItem.find_by(id: @now_sample_id)).to be
          expect(CartItem.find_by(id: @later_sample_id)).to be
        end
      end

      context "when the later_bin is missing" do
        before do
          base_chassis.later_bin = nil
        end

        it "doesn't restore the later_bin" do
          expect(base_chassis.later_bin).to be_nil

          base_chassis.destroy_all_items_for_later

          expect(base_chassis.later_bin).to be_nil
        end

        it "returns false" do
          expect(base_chassis.destroy_all_items_for_later).to eql(false)
        end
      end

      context "when the later_bin is present but contains no items" do

        before do
          @later_bin = base_now_items_chassis.later_bin
          @now_items_count = base_now_items_chassis.now_items.count
          @later_items_count = base_now_items_chassis.later_items.count
        end

        it "does not destroy the underlying cart-object" do
          #test validation:
          expect(base_now_items_chassis.later_items.count).to eql(0)
          expect(@later_bin).to eql(base_now_items_chassis.later_bin)
          expect(base_now_items_chassis.later_bin).to be
          expect(@later_bin).to be

          base_now_items_chassis.destroy_all_items_for_later

          #test
          expect(@later_bin).to be
          expect(base_now_items_chassis.later_bin).to eql(@later_bin)
          expect(base_now_items_chassis.later_bin.present?).to eql(true)
        end

        it "does not affect items in the now_bin" do
          #test validation:
          expect(base_now_items_chassis.now_items.count).to eql(@now_items_count)
          expect(base_now_items_chassis.now_items.count).to be > 0

          base_now_items_chassis.destroy_all_items_for_later

          #test
          expect(base_now_items_chassis.now_items.count).to eql(@now_items_count)
        end

        it "returns true" do
          #test
          expect(base_later_items_chassis.destroy_all_items_for_later).to eql(true)
        end
      end

      context "when the later_bin is present and contains basic items" do

        before do
          @later_bin = base_full_chassis.later_bin
          @rando_later_item = base_full_chassis.later_bin.cart_items[0]
          @rando_later_item_id = base_full_chassis.later_bin.cart_items[0].id
          @now_items_count = base_full_chassis.now_items.count
          @later_items_count = base_full_chassis.later_items.count
        end

        it "does not destroy the underlying cart-object" do
          #test validation:
          expect(base_full_chassis.now_items.count).to be > 0
          expect(@later_bin).to eql(base_full_chassis.later_bin)
          expect(@later_bin).to be

          base_full_chassis.destroy_all_items_for_later

          #test
          expect(@later_bin).to be
          expect(base_full_chassis.later_items.count).to eql(0)
          expect(base_full_chassis.later_bin.present?).to eql(true)
          expect(base_full_chassis.later_bin).to eql(@later_bin)
        end

        it "reduces the number of items in the now_bin to zero" do
          #test validation:
          expect(base_full_chassis.later_items.count).to be > 0

          base_full_chassis.destroy_all_items_for_later

          expect(base_full_chassis.later_items.count).to eql(0)
        end

        it "returns true" do
          expect(base_full_chassis.destroy_all_items_for_later).to eql(true)
        end

        it "destroys the cart_items that were in the now_bin" do
          #Test validation:
          expect(@rando_later_item).to be
          expect(@rando_later_item.cart).to eql(base_full_chassis.later_bin)
          expect(CartItem.find_by(id: @rando_later_item_id).present?).to eql(true)

          base_full_chassis.destroy_all_items_for_later

          #test
          expect(CartItem.find_by(id: @rando_later_item_id).present?).to eql(false)
        end
      end

      context "when the now_bin is present and contains items with unpaid reservations" do

        before do
          @later_bin = unpaid_reservations_chassis.later_bin
          @rando_later_item = unpaid_reservations_chassis.later_bin.cart_items[0]
          @rando_later_item_id = unpaid_reservations_chassis.later_bin.cart_items[0].id
          @rando_later_item_holdable = unpaid_reservations_chassis.later_bin.cart_items[0].holdable
          @rando_later_item_holdable_id = unpaid_reservations_chassis.later_bin.cart_items[0].holdable.id
          @rando_later_item_holdable_user = unpaid_reservations_chassis.later_bin.cart_items[0].holdable.user
          @now_items_count = unpaid_reservations_chassis.now_items.count
          @later_items_count = unpaid_reservations_chassis.later_items.count
        end

        it "reduces the number of items in the later_bin to zero" do
          #test validation:
          expect(unpaid_reservations_chassis.later_items.count).to be > 0

          unpaid_reservations_chassis.destroy_all_items_for_later

          expect(unpaid_reservations_chassis.later_items.count).to eql(0)
        end

        it "returns true" do
          expect(unpaid_reservations_chassis.destroy_all_items_for_later).to eql(true)
        end

        it "destroys the cart_items that were in the now_bin" do
          #Test validation:
          expect(@rando_later_item).to be
          expect(@rando_later_item.cart).to eql(unpaid_reservations_chassis.later_bin)
          expect(CartItem.find_by(id: @rando_later_item_id).present?).to eql(true)

          unpaid_reservations_chassis.destroy_all_items_for_later

          #test
          expect(CartItem.find_by(id: @rando_later_item_id).present?).to eql(false)
        end


        it "does not destroy the unpaid reservations" do
          expect(CartItem.find_by(id: @rando_later_item_id).present?).to eql(true)
          expect(Reservation.find_by(id: @rando_later_item_holdable_id).present?).to eql(true)

          unpaid_reservations_chassis.destroy_all_items_for_later

          expect(CartItem.find_by(id: @rando_later_item_id).present?).to eql(false)
          expect(Reservation.find_by(id: @rando_later_item_holdable_id).present?).to eql(true)
        end

        it "does not dissociate the unpaid reservations from its original user" do
          expect(CartItem.find_by(id: @rando_later_item_id).present?).to eql(true)
          expect(Reservation.find_by(id: @rando_later_item_holdable).user).to eql(@rando_later_item_holdable_user)

          unpaid_reservations_chassis.destroy_all_items_for_later

          expect(CartItem.find_by(id: @rando_later_item_id).present?).to eql(false)
          expect(Reservation.find_by(id: @rando_later_item_holdable_id).user).to eql(@rando_later_item_holdable_user)
        end
      end
    end

    describe "#destroy_all_cart_contents" do
      context "when both bins are missing" do

        before do
          base_full_chassis.now_bin = nil
          base_full_chassis.later_bin = nil
        end

        it "doesn't restore either of the bins" do
          expect(base_full_chassis.now_bin).to be_nil
          expect(base_full_chassis.later_bin).to be_nil
          expect(base_full_chassis.all_items_count).to eql(0)

          base_full_chassis.destroy_all_cart_contents

          expect(base_full_chassis.now_bin).to be_nil
          expect(base_full_chassis.later_bin).to be_nil
          expect(base_full_chassis.all_items_count).to eql(0)
        end

        it "returns false" do
          expect(base_full_chassis.destroy_all_cart_contents).to eql(false)
        end
      end

      context "when the bins are present but contain no items" do

        before do
          @later_bin = base_chassis.later_bin
          @later_bin_id = base_chassis.later_bin.id

          @now_bin = base_chassis.now_bin
          @now_bin_id = base_chassis.now_bin.id
        end

        it "does not detroy the underlying cart_object for either bin" do
          #test validation:
          expect(@later_bin).to be
          expect(@later_bin).to eql(base_chassis.later_bin)

          expect(@now_bin).to be
          expect(@now_bin).to eql(base_chassis.now_bin)

          # Test Act:
          base_chassis.destroy_all_cart_contents

          #test
          expect(@later_bin).to be
          expect(@now_bin).to be
          expect(base_chassis.later_bin).to eql(@later_bin)
          expect(base_chassis.now_bin).to eql(@now_bin)
          expect(base_chassis.now_bin.present?).to eql(true)
          expect(base_chassis.later_bin.present?).to eql(true)
        end

        it "returns true" do
          expect(base_chassis.destroy_all_cart_contents).to eql(true)
        end
      end

      context "when the bins are present and contain paid reservation items" do
        before do
          @later_bin = unpaid_reservations_chassis.later_bin
          @later_items_count = unpaid_reservations_chassis.later_items.count

          @now_bin = unpaid_reservations_chassis.now_bin
          @now_items_count = unpaid_reservations_chassis.now_items.count

          @rando_later_item = unpaid_reservations_chassis.later_bin.cart_items[0]
          @rando_later_item_id = unpaid_reservations_chassis.later_bin.cart_items[0].id
          @rando_later_item_holdable = unpaid_reservations_chassis.later_bin.cart_items[0].holdable
          @rando_later_item_holdable_id = unpaid_reservations_chassis.later_bin.cart_items[0].holdable.id
          @rando_later_item_holdable_user = unpaid_reservations_chassis.later_bin.cart_items[0].holdable.user

          @rando_now_item = unpaid_reservations_chassis.now_bin.cart_items[0]
          @rando_now_item_id = unpaid_reservations_chassis.now_bin.cart_items[0].id
          @rando_now_item_holdable = unpaid_reservations_chassis.now_bin.cart_items[0].holdable
          @rando_now_item_holdable_id = unpaid_reservations_chassis.now_bin.cart_items[0].holdable.id
          @rando_now_item_holdable_user = unpaid_reservations_chassis.now_bin.cart_items[0].holdable.user
        end

        it "reduces the number of items in both bins to zero" do
          #test validation:
          expect(unpaid_reservations_chassis.later_items.count).to be > 0
          expect(unpaid_reservations_chassis.now_items.count).to be > 0

          unpaid_reservations_chassis.destroy_all_cart_contents

          expect(unpaid_reservations_chassis.later_items.count).to eql(0)
          expect(unpaid_reservations_chassis.now_items.count).to eql(0)
        end

        it "returns true" do
          expect(unpaid_reservations_chassis.destroy_all_cart_contents).to eql(true)
        end

        it "destroys the cart_items that were in the now_bin" do
          #Test validation:
          expect(@rando_later_item).to be
          expect(@rando_later_item.cart).to eql(unpaid_reservations_chassis.later_bin)
          expect(CartItem.find_by(id: @rando_later_item_id).present?).to eql(true)

          expect(@rando_now_item).to be
          expect(@rando_now_item.cart).to eql(unpaid_reservations_chassis.now_bin)
          expect(CartItem.find_by(id: @rando_now_item_id).present?).to eql(true)

          unpaid_reservations_chassis.destroy_all_cart_contents

          #test
          expect(CartItem.find_by(id: @rando_later_item_id).present?).to eql(false)
          expect(CartItem.find_by(id: @rando_now_item_id).present?).to eql(false)
        end


        it "does not destroy the unpaid reservations" do
          expect(CartItem.find_by(id: @rando_later_item_id).present?).to eql(true)
          expect(Reservation.find_by(id: @rando_later_item_holdable_id).present?).to eql(true)

          expect(CartItem.find_by(id: @rando_now_item_id).present?).to eql(true)
          expect(Reservation.find_by(id: @rando_now_item_holdable_id).present?).to eql(true)

          unpaid_reservations_chassis.destroy_all_cart_contents

          expect(CartItem.find_by(id: @rando_later_item_id).present?).to eql(false)
          expect(Reservation.find_by(id: @rando_later_item_holdable_id).present?).to eql(true)

          expect(CartItem.find_by(id: @rando_now_item_id).present?).to eql(false)
          expect(Reservation.find_by(id: @rando_now_item_holdable_id).present?).to eql(true)
        end

        it "does not dissociate the unpaid reservations from their original users" do
          expect(CartItem.find_by(id: @rando_later_item_id).present?).to eql(true)
          expect(Reservation.find_by(id: @rando_later_item_holdable).user).to eql(@rando_later_item_holdable_user)

          expect(CartItem.find_by(id: @rando_now_item_id).present?).to eql(true)
          expect(Reservation.find_by(id: @rando_now_item_holdable).user).to eql(@rando_now_item_holdable_user)

          unpaid_reservations_chassis.destroy_all_cart_contents

          expect(CartItem.find_by(id: @rando_later_item_id).present?).to eql(false)
          expect(Reservation.find_by(id: @rando_later_item_holdable_id).user).to eql(@rando_later_item_holdable_user)

          expect(CartItem.find_by(id: @rando_now_item_id).present?).to eql(false)
          expect(Reservation.find_by(id: @rando_now_item_holdable_id).user).to eql(@rando_now_item_holdable_user)
        end
      end
    end

    describe "#now_items_count" do
      context "when the now_bin is missing" do
        before do
          base_full_chassis.now_bin = nil
        end

        it "returns zero" do
          #test validation:
          expect(base_full_chassis.now_bin).to be_nil

          #test
          expect(base_full_chassis.now_items_count).to eql(0)
        end
      end

      context "when the now_bin is present but contains no items" do

        it "returns zero" do
          #test validation:
          expect(base_chassis.now_bin).to be
          expect(base_chassis.now_bin.cart_items.count).to eql(0)

          #test
          expect(base_chassis.now_items_count).to eql(0)
        end
      end

      context "when the now_bin is present and contains items" do
        it "returns the number of cart_items in the now_bin" do
          #test validation:
          expect(base_full_chassis.now_bin).to be
          expect(base_full_chassis.now_bin.cart_items.count).to be > 0

          initial_now_count = base_full_chassis.now_bin.cart_items.count

          #test
          expect(base_full_chassis.now_items_count).to eql(initial_now_count)
        end

        it "counts only the contents of the now_bin" do
          # Test validation:
          initial_now_count = base_full_chassis.now_bin.cart_items.count
          expect(initial_now_count).to be > 0
          initial_later_count = base_full_chassis.later_bin.cart_items.count
          expect(initial_later_count).to be > 0

          # Test:
          expect(base_full_chassis.now_items_count).to be < (initial_now_count + initial_later_count)
        end
      end
    end

    describe "#later_items_count" do
      context "when the later_bin is missing" do
        before do
          base_full_chassis.later_bin = nil
        end

        it "returns zero" do
          #test validation:
          expect(base_full_chassis.later_bin).to be_nil

          #test
          expect(base_full_chassis.later_items_count).to eql(0)
        end
      end

      context "when the later_bin is present but contains no items" do

        it "returns zero" do
          #test validation:
          expect(base_chassis.later_bin).to be
          expect(base_chassis.now_bin.cart_items.count).to eql(0)

          #test
          expect(base_chassis.later_items_count).to eql(0)
        end
      end

      context "when the later_bin is present and contains items" do
        it "returns the number of cart_items in the now_bin" do
          #test validation:
          expect(base_full_chassis.later_bin).to be
          expect(base_full_chassis.later_bin.cart_items.count).to be > 0

          initial_later_count = base_full_chassis.later_bin.cart_items.count

          #test
          expect(base_full_chassis.later_items_count).to eql(initial_later_count)
        end

        it "counts only the contents of the later_bin" do
          #Test validation:
          initial_now_count = base_full_chassis.now_bin.cart_items.count
          expect(initial_now_count).to be > 0

          initial_later_count = base_full_chassis.later_bin.cart_items.count
          expect(initial_later_count).to be > 0

          # Test:
          expect(base_full_chassis.later_items_count).to be < (initial_now_count + initial_later_count)
        end
      end
    end

    describe "#all_items_count" do
      context "when both bins are missing" do

        before do
          base_full_chassis.later_bin = nil
          base_full_chassis.now_bin = nil
        end

        it "returns zero" do
          #test validation:
          expect(base_full_chassis.later_bin).to be_nil
          expect(base_full_chassis.now_bin).to be_nil

          #test
          expect(base_full_chassis.all_items_count).to eql(0)
        end
      end

      context "when one bin is missing" do
        context "when the other bin contains no items" do

          before do
            base_chassis.now_bin = nil
          end

          it "returns zero" do
            #test validation:
            expect(base_chassis.later_bin).to be
            expect(base_chassis.now_bin).to be_nil

            #test
            expect(base_chassis.all_items_count).to eql(0)
          end
        end

        context "when the other bin contains basic items" do
          before do
            base_full_chassis.later_bin = nil
          end

          it "returns the number of items in the extant bin" do
            #test validation:
            expect(base_full_chassis.later_bin).to be_nil
            expect(base_full_chassis.now_bin).to be
            expect(base_full_chassis.now_bin.cart_items.count).to be > 0
            initial_now_items_count = base_full_chassis.now_bin.cart_items.count

            #test
            expect(base_full_chassis.all_items_count).to eql(initial_now_items_count)
          end
        end
      end

      context "when both bins are present and contain items" do
        before do
          rando_item.update_attribute(:cart, base_full_chassis.later_bin)
        end

        it "returns the combined number of items in the saved and unsaved carts" do
          expect(base_full_chassis.now_bin.cart_items.count).to be > 0
          expect(base_full_chassis.later_bin.cart_items.count).to be > 0

          initial_now_count = base_full_chassis.now_bin.cart_items.count
          initial_later_count = base_full_chassis.later_bin.cart_items.count

          expect(initial_now_count == initial_later_count).to eql(false)

          expect(base_full_chassis.all_items_count).to be > (base_full_chassis.now_items_count * 2)

          expect(base_full_chassis.all_items_count).to be < (base_full_chassis.later_items_count * 2)

          expect(base_full_chassis.all_items_count).to eql(initial_now_count + initial_later_count)
        end
      end
    end

    describe "#verify_avail_for_items_for_now" do

      context "when the now_bin is missing" do
        before do
          base_full_chassis.now_bin = nil
        end

        it "returns false" do
          #Test validation
          expect(base_full_chassis.now_bin).to be_nil

          #actual test:
          expect(base_full_chassis.verify_avail_for_items_for_now[:verified]).to eql(false)
        end

        it "does not report any problem items" do
          problems = base_full_chassis.verify_avail_for_items_for_now
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when the now_bin is present but contains no items" do
        it "returns false" do
          #Test validation
          expect(base_chassis.now_bin.present?).to eql(true)
          expect(base_chassis.now_items.present?).to eql(false)

          #actual test:
          expect(base_chassis.verify_avail_for_items_for_now[:verified]).to eql(false)
        end

        it "does not report any problem items" do
          problems = base_chassis.verify_avail_for_items_for_now
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when the now_bin contains items" do
        context "when the now_bin contains only valid, basic items" do
          it "returns true" do
            expect(base_full_chassis.verify_avail_for_items_for_now[:verified]).to eql(true)
          end

          it "does not report any problem items" do
            problems = base_full_chassis.verify_avail_for_items_for_now
            expect(problems[:problem_items]).to be_a_kind_of(Array)
            expect(problems[:problem_items].empty?).to eql(true)
          end
        end

        context "when the now_bin contains only valid items with unpaid reservations" do
          it "returns true" do
            expect(unpaid_reservations_chassis.verify_avail_for_items_for_now[:verified]).to eql(true)
          end

          it "does not report any problem items" do
            problems = unpaid_reservations_chassis.verify_avail_for_items_for_now
            expect(problems[:problem_items]).to be_a_kind_of(Array)
            expect(problems[:problem_items].empty?).to eql(true)
          end
        end

        context "when the now_bin contains only valid items with paid reservations" do
          it "returns true" do
            expect(paid_reservations_chassis.verify_avail_for_items_for_now[:verified]).to eql(true)
          end

          it "does not report any problem items" do
            problems = paid_reservations_chassis.verify_avail_for_items_for_now
            expect(problems[:problem_items]).to be_a_kind_of(Array)
            expect(problems[:problem_items].empty?).to eql(true)
          end
        end

        context "when the now_bin contains an item with an expired membership, plus several valid, basic items" do
          before do
            expired_membership_item.update_attribute(:cart, base_full_chassis.now_bin)
          end

          it "returns false" do
            #test validation
            expect(expired_membership_item.cart).to eql(base_full_chassis.now_bin)

            expect(base_full_chassis.now_items_count).to eql(base_full_chassis.later_items_count + 1)

            expect(base_full_chassis.verify_avail_for_items_for_now[:verified]).to eql(false)
          end

          it "reports the item with the expired membership as its sole problem item" do
            problems = base_full_chassis.verify_avail_for_items_for_now
            expect(problems[:problem_items]).to be_a_kind_of(Array)
            expect(problems[:problem_items].length).to eql(1)
            expect(problems[:problem_items][0]).to eql(expired_membership_item.quick_description)
          end

          it "results in the item with the expired membership being marked 'unavailable'" do
            expect(expired_membership_item.available).to eql(true)
            base_full_chassis.verify_avail_for_items_for_now
            expired_membership_item.reload
            expect(expired_membership_item.reload.available).to eql(false)
          end
        end

        context "when the now_bin contains a reservation item with a missing benefitable, plus several valid, basic items" do

          before do
            rando_item.update_attribute(:cart, base_full_chassis.now_bin)
            rando_item.update_attribute(:benefitable, nil)
          end

          it "returns true" do
            #test validation
            expect(rando_item).to be
            expect(rando_item.benefitable).to be_nil
            expect(rando_item.cart).to eql(base_full_chassis.now_bin)

            expect(base_full_chassis.now_items_count).to eql(base_full_chassis.later_items_count + 1)

            expect(base_full_chassis.verify_avail_for_items_for_now[:verified]).to eql(true)
          end

          it "Does not report any problem items" do
            problems = base_full_chassis.verify_avail_for_items_for_now
            expect(problems[:problem_items]).to be_a_kind_of(Array)
            expect(problems[:problem_items].length).to eql(0)
          end

          it "does not result in a change to the item with the missing benefitable's 'available' attribute" do
            expect(rando_item.available).to eql(true)
            base_full_chassis.verify_avail_for_items_for_now
            expect(rando_item.reload.available).to eql(true)
          end
        end

        context "when the now_bin contains a reservation item with a mismatched price memo" do

          before do
            price_altered_item.update_attribute(:cart, base_full_chassis.now_bin)
          end

          it "returns false" do
            #test validation
            expect(price_altered_item).to be
            expect(price_altered_item.cart).to eql(base_full_chassis.now_bin)

            expect(base_full_chassis.now_items_count).to eql(base_full_chassis.later_items_count + 1)

            expect(base_full_chassis.verify_avail_for_items_for_now[:verified]).to eql(false)
          end

          it "reports the item with the mismatched price memo as its sole problem item" do
            problems = base_full_chassis.verify_avail_for_items_for_now
            expect(problems[:problem_items]).to be_a_kind_of(Array)
            expect(problems[:problem_items].length).to eql(1)
            expect(problems[:problem_items][0]).to eql(price_altered_item.quick_description)
          end

          it "results in the item with the mismatched price being marked 'unavailable'" do
            expect(price_altered_item.available).to eql(true)

            base_full_chassis.verify_avail_for_items_for_now
            #price_altered_item.reload
            expect(price_altered_item.reload.available).to eql(false)
          end
        end

        context "when the now_bin contains an item that was perviously marked 'unavailable', plus several valid, basic items" do
          before do
            unavailable_item.update_attribute(:cart, base_full_chassis.now_bin)
          end

          it "returns verified:false, problem_items[]" do
            #test validation
            expect(unavailable_item).to be
            expect(unavailable_item.cart).to eql(base_full_chassis.now_bin)

            expect(base_full_chassis.now_items_count).to eql(base_full_chassis.later_items_count + 1)

            expect(base_full_chassis.verify_avail_for_items_for_now[:verified]).to eql(false)
          end

          it "reports the item marked unavailable as its sole problem item" do
            problems = base_full_chassis.verify_avail_for_items_for_now
            expect(problems[:problem_items]).to be_a_kind_of(Array)
            expect(problems[:problem_items].length).to eql(1)
            expect(problems[:problem_items][0]).to eql(unavailable_item.quick_description)
          end

          it "results in no change to the value of the unavailable item's 'available' attribute" do
            initial_availability = price_altered_item.available
            base_full_chassis.verify_avail_for_items_for_now
            expect(price_altered_item.reload.available).to eql(initial_availability)
          end
        end
      end
    end

    describe "#verify_avail_for_saved_items" do
      context "when the later_bin is missing" do
        before do
          base_full_chassis.later_bin = nil
        end

        it "returns false" do
          #Test validation
          expect(base_full_chassis.later_bin).to be_nil

          #actual test:
          expect(base_full_chassis.verify_avail_for_saved_items[:verified]).to eql(false)
        end

        it "does not report any problem items" do
          problems = base_full_chassis.verify_avail_for_saved_items
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when the later_bin is present but contains no items" do
        it "returns false" do
          expect(base_chassis.verify_avail_for_saved_items[:verified]).to eql(false)
        end

        it "does not report any problem items" do
          problems = base_chassis.verify_avail_for_saved_items
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when the later_bin contains items" do
        context "when the later_bin contains only valid, basic items" do
          it "returns true" do
            expect(base_full_chassis.verify_avail_for_saved_items[:verified]).to eql(true)
          end

          it "does not report any problem items" do
            problems = base_full_chassis.verify_avail_for_saved_items
            expect(problems[:problem_items]).to be_a_kind_of(Array)
            expect(problems[:problem_items].empty?).to eql(true)
          end
        end

        context "when the later_bin contains only valid items with unpaid reservations" do
          it "returns true" do
            expect(unpaid_reservations_chassis.verify_avail_for_saved_items[:verified]).to eql(true)
          end

          it "does not report any problem items" do
            problems = unpaid_reservations_chassis.verify_avail_for_saved_items
            expect(problems[:problem_items]).to be_a_kind_of(Array)
            expect(problems[:problem_items].empty?).to eql(true)
          end
        end

        context "when the later_bin contains only valid items with paid reservations" do
          it "returns true" do
            expect(paid_reservations_chassis.verify_avail_for_saved_items[:verified]).to eql(true)
          end

          it "does not report any problem items" do
            problems = paid_reservations_chassis.verify_avail_for_saved_items
            expect(problems[:problem_items]).to be_a_kind_of(Array)
            expect(problems[:problem_items].empty?).to eql(true)
          end
        end

        context "when the later_bin contains an item with an expired membership, plus several valid, basic items" do
          before do
            expired_membership_item.update_attribute(:cart, base_full_chassis.later_bin)
          end

          it "returns false" do
            #test validation
            expect(expired_membership_item.cart).to eql(base_full_chassis.later_bin)

            expect(base_full_chassis.later_items_count).to eql(base_full_chassis.now_items_count + 1)

            expect(base_full_chassis.verify_avail_for_saved_items[:verified]).to eql(false)
          end

          it "reports the item with the expired membership as its sole problem item" do
            problems = base_full_chassis.verify_avail_for_saved_items
            expect(problems[:problem_items]).to be_a_kind_of(Array)
            expect(problems[:problem_items].length).to eql(1)
            expect(problems[:problem_items][0]).to eql(expired_membership_item.quick_description)
          end

          it "results in the item with the expired membership being marked 'unavailable'" do
            expect(expired_membership_item.available).to eql(true)
            base_full_chassis.verify_avail_for_saved_items
            expect(expired_membership_item.reload.available).to eql(false)
          end
        end

        context "when the later_bin contains a reservation item with a missing benefitable, plus several valid, basic items" do

          before do
            rando_item.update_attribute(:cart, base_full_chassis.later_bin)
            rando_item.update_attribute(:benefitable, nil)
          end

          it "returns true" do
            #test validation
            expect(rando_item).to be
            expect(rando_item.benefitable).to be_nil
            expect(rando_item.cart).to eql(base_full_chassis.later_bin)

            expect(base_full_chassis.later_items_count).to eql(base_full_chassis.now_items_count + 1)

            expect(base_full_chassis.verify_avail_for_saved_items[:verified]).to eql(true)
          end

          it "does not report any problem items" do
            problems = base_full_chassis.verify_avail_for_saved_items
            expect(problems[:problem_items]).to be_a_kind_of(Array)
            expect(problems[:problem_items].length).to eql(0)
          end

          it "results in the item with the missing benefitable being marked 'unavailable'" do
            expect(rando_item.available).to eql(true)
            base_full_chassis.verify_avail_for_saved_items
            expect(rando_item.reload.available).to eql(true)
          end
        end

        context "when the later_bin contains a reservation item with a mismatched price memo" do

          before do
            price_altered_item.update_attribute(:cart, base_full_chassis.later_bin)
          end

          it "returns false" do
            #test validation
            expect(price_altered_item).to be
            expect(price_altered_item.cart).to eql(base_full_chassis.later_bin)

            expect(base_full_chassis.later_items_count).to eql(base_full_chassis.now_items_count + 1)

            expect(base_full_chassis.verify_avail_for_saved_items[:verified]).to eql(false)
          end

          it "reports the item with the missing benefitable as its sole problem item" do
            problems = base_full_chassis.verify_avail_for_saved_items
            expect(problems[:problem_items]).to be_a_kind_of(Array)
            expect(problems[:problem_items].length).to eql(1)
            expect(problems[:problem_items][0]).to eql(price_altered_item.quick_description)
          end

          it "results in the item with the mismatched price being marked 'unavailable'" do
            expect(price_altered_item.available).to eql(true)

            base_full_chassis.verify_avail_for_saved_items

            expect(price_altered_item.reload.available).to eql(false)
          end
        end

        context "when the later_bin contains an item that was perviously marked 'unavailable', plus several valid, basic items" do
          before do
            unavailable_item.update_attribute(:cart, base_full_chassis.later_bin)
          end

          it "returns verified:false, problem_items[]" do
            #test validation
            expect(unavailable_item).to be
            expect(unavailable_item.cart).to eql(base_full_chassis.later_bin)

            expect(base_full_chassis.later_items_count).to eql(base_full_chassis.now_items_count + 1)

            expect(base_full_chassis.verify_avail_for_saved_items[:verified]).to eql(false)
          end

          it "reports the item marked unavailable as its sole problem item" do
            problems = base_full_chassis.verify_avail_for_saved_items
            expect(problems[:problem_items]).to be_a_kind_of(Array)
            expect(problems[:problem_items].length).to eql(1)
            expect(problems[:problem_items][0]).to eql(unavailable_item.quick_description)
          end

          it "results in no change to the value of the unavailable item's 'available' attribute" do
            initial_availability = price_altered_item.available
            base_full_chassis.verify_avail_for_items_for_now
            expect(price_altered_item.reload.available).to eql(initial_availability)
          end
        end
      end
    end

    describe "#verify_avail_for_all_items" do
      context "when both bins are missing" do
        before  do
          base_full_chassis.now_bin = nil
          base_full_chassis.later_bin = nil
        end

        it "returns false" do
          # Test validations:
          expect(base_full_chassis.now_bin).to be_nil
          expect(base_full_chassis.later_bin).to be_nil

          # Test:
          expect(base_full_chassis.verify_avail_for_all_items[:verified]).to eql(false)
        end

        it "does not report any problem items" do
          problems = base_full_chassis.verify_avail_for_all_items
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
      end
      end

      context "when both bins are empty" do
        it "returns false" do
          expect(base_chassis.verify_avail_for_all_items[:verified]).to eql(false)
        end

        it "does not report any problem items" do
          problems = base_chassis.verify_avail_for_all_items
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when both bins contain valid_basic items" do
        it "returns true" do
          expect(base_full_chassis.verify_avail_for_all_items[:verified]).to eql(true)
        end

        it "does not report any problem items" do
          problems = base_full_chassis.verify_avail_for_all_items
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end


      context "when one bin is missing, but the now_bin contains valid, basic items" do
        before do
          base_full_chassis.now_bin = nil
        end

        it "returns true" do
          #Test validation
          expect(base_full_chassis.now_bin).to be_nil
          expect(base_full_chassis.later_items.count).to be > 0
          expect(base_full_chassis.verify_avail_for_all_items[:verified]).to eql(true)
        end

        it "does not report any problem items" do
          problems = base_full_chassis.verify_avail_for_all_items
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when one bin is empty, and the other bin contains valid, basic items" do

        it "returns true" do
          #Test validation
          expect(base_now_items_chassis.now_items_count).to be > 0
          expect(base_now_items_chassis.later_items.count).to eql(0)

          expect(base_now_items_chassis.verify_avail_for_all_items[:verified]).to eql(true)
        end

        it "does not report any problem items" do
          problems = base_now_items_chassis.verify_avail_for_all_items
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when the now_bin contains valid, basic items and the later_bin contains both valid, basic items and an item with an expired membership" do
        before do
          expired_membership_item.update_attribute(:cart, base_full_chassis.later_bin)
        end

        it "returns false" do
          expect(base_full_chassis.now_items_count).to be > 0
          expect(base_full_chassis.now_items_count).to be < base_full_chassis.later_items_count

          expect(base_full_chassis.verify_avail_for_all_items[:verified]).to eql(false)
        end

        it "reports the item with the expired membership as its sole problem item" do
          problems = base_full_chassis.verify_avail_for_all_items
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].length).to eql(1)
          expect(problems[:problem_items][0]).to eql(expired_membership_item.quick_description)
        end

        it "marks the item with the expired membership as unavailable" do
          expect(expired_membership_item.available).to eql(true)
          base_full_chassis.verify_avail_for_all_items
          expect(expired_membership_item.reload.available).to eql(false)
        end
      end

      context "when the later_bin contains valid, basic items and the now_bin contains both valid, basic items and an item with an expired membership" do
        before do
          expired_membership_item.update_attribute(:cart, base_full_chassis.later_bin)
        end

        it "returns false" do
          expect(base_full_chassis.later_items_count).to be > 0
          expect(base_full_chassis.later_items_count).to eql(base_full_chassis.now_items_count + 1)

          expect(base_full_chassis.verify_avail_for_all_items[:verified]).to eql(false)
        end

        it "reports the item with the expired membership as its sole problem item" do
          problems = base_full_chassis.verify_avail_for_all_items
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].length).to eql(1)
          expect(problems[:problem_items][0]).to eql(expired_membership_item.quick_description)
        end

        it "marks the item with the expired membership as unavailable" do
          expect(expired_membership_item.available).to eql(true)
          base_full_chassis.verify_avail_for_all_items
          expect(expired_membership_item.reload.available).to eql(false)
        end
      end

      context "when both bins contain only valid items with unpaid reservations" do
        it "returns true" do
          expect(unpaid_reservations_chassis.verify_avail_for_all_items[:verified]).to eql(true)
        end

        it "does not report any problem items" do
          problems = unpaid_reservations_chassis.verify_avail_for_all_items
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when both bins contain only valid items with partially paid reservations" do
        it "returns true" do
          expect(partially_paid_reservations_chassis.verify_avail_for_all_items[:verified]).to eql(true)
        end

        it "does not report any problem items" do
          problems = partially_paid_reservations_chassis.verify_avail_for_all_items
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when both bins contain only valid items with fully paid reservations" do
        it "returns true" do
          expect(paid_reservations_chassis.verify_avail_for_all_items[:verified]).to eql(true)
        end

        it "does not report any problem items" do
          problems = paid_reservations_chassis.verify_avail_for_all_items
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end
    end

    describe "#can_proceed_to_payment?" do
      context "when both bins are missing" do

        before  do
          base_full_chassis.now_bin = nil
          base_full_chassis.later_bin = nil
        end

        it "returns false" do
          expect(base_full_chassis.now_bin).to be_nil
          expect(base_full_chassis.later_bin).to be_nil
          expect(base_full_chassis.can_proceed_to_payment?[:verified]).to eql(false)
        end

        it "doesn't report any problem items" do
          problems = base_full_chassis.can_proceed_to_payment?
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when both bins are empty" do
        it "returns false" do
          expect(base_chassis.can_proceed_to_payment?[:verified]).to eql(false)
        end

        it "doesn't report any problem items" do
          problems = base_chassis.can_proceed_to_payment?
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when the now_bin is empty, and the later_bin contains valid, basic items" do
        it "returns false" do
          expect(base_later_items_chassis.can_proceed_to_payment?[:verified]).to eql(false) #perturbed
        end

        it "doesn't report any problem items" do
          problems = base_later_items_chassis.can_proceed_to_payment?
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when the now_bin is missing, but the later_bin contains valid, basic items" do
        before do
          base_full_chassis.now_bin = nil
        end

        it "returns false" do
          expect(base_full_chassis.can_proceed_to_payment?[:verified]).to eql(false)
        end

        it "doesn't report any problem items" do
          problems = base_full_chassis.can_proceed_to_payment?
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when the now_bin is empty, but the later_bin contains valid, basic items" do
        it "returns false" do
          expect(base_later_items_chassis.can_proceed_to_payment?[:verified]).to eql(false)
        end

        it "doesn't report any problem items" do
          problems = base_later_items_chassis.can_proceed_to_payment?
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when both bins contain only unpaid reservation items" do

        it "returns true" do
          expect(unpaid_reservations_chassis.can_proceed_to_payment?[:verified]).to eql(true)
        end

        it "doesn't report any problem items" do
          problems = unpaid_reservations_chassis.can_proceed_to_payment?
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when both bins contain only partially paid reservation items" do
        it "returns true" do
          expect(partially_paid_reservations_chassis.can_proceed_to_payment?[:verified]).to eql(true)
        end

        it "doesn't report any problem items" do
          problems = partially_paid_reservations_chassis.can_proceed_to_payment?
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when both bins contain only paid reservation items" do
        it "returns true" do
          expect(paid_reservations_chassis.can_proceed_to_payment?[:verified]).to eql(true)
        end

        it "doesn't report any problem items" do
          problems = paid_reservations_chassis.can_proceed_to_payment?
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end

      context "when the now_bin contains a reservation item with a missing benefitable, plus several valid, basic items" do

        before do
          rando_item.update_attribute(:cart, base_full_chassis.now_bin)
          rando_item.update_attribute(:benefitable, nil)
        end

        it "returns true" do
          #test validation
          expect(rando_item).to be
          expect(rando_item.benefitable).to be_nil
          expect(rando_item.cart).to eql(base_full_chassis.now_bin)

          expect(base_full_chassis.now_items_count).to eql(base_full_chassis.later_items_count + 1)

          expect(base_full_chassis.can_proceed_to_payment?[:verified]).to eql(false)
        end

        it "Reports the item with the missing benefitable as its one problem item" do
          problems = base_full_chassis.can_proceed_to_payment?
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].length).to eql(1)
          expect(problems[:problem_items][0]).to eql(rando_item.quick_description)
        end

        it "does not result in a change to the item with the missing benefitable's 'available' attribute" do
          expect(rando_item.available).to eql(true)
          base_full_chassis.can_proceed_to_payment?
          expect(rando_item.reload.available).to eql(true)
        end
      end

      context "when the now_bin contains an expired membership item in addition to several valid, basic items, and the later_bin contains only valid, basic items" do

        before do
          expired_membership_item.update_attribute(:cart, base_full_chassis.now_bin)
        end

        it "returns false" do
          expect(base_full_chassis.can_proceed_to_payment?[:verified]).to eql(false)
        end

        it "reports the expired membership item as its sole problem item" do
          problems = base_full_chassis.can_proceed_to_payment?
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].length).to eql(1)
          expect(problems[:problem_items][0]).not_to eql(expired_membership_item) #inverted
        end
      end



      context "when the later_bin contains an expired membership item in addition to several valid, basic items, and the now_bin contains only valid, basic items" do
        before do
          expired_membership_item.update_attribute(:cart, base_full_chassis.later_bin)
        end

        it "returns false" do
          expect(base_full_chassis.can_proceed_to_payment?[:verified]).to eql(true)
        end

        it "does not report any problem items" do
          problems = base_full_chassis.can_proceed_to_payment?
          expect(problems[:problem_items]).to be_a_kind_of(Array)
          expect(problems[:problem_items].empty?).to eql(true)
        end
      end
    end

    describe "#payment_by_check_allowed?" do
      it "returns true" do
        expect(base_full_chassis.payment_by_check_allowed?).to eql(true)
      end
    end
  end
end
