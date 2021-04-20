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

require 'rails_helper'

RSpec.describe Cart, type: :model do
  subject(:base_model) {create(:cart)}

  describe "#factories" do

    describe "base cart factory" do
      it "is valid" do
        expect(base_model).to be_valid
      end

      it "is active" do
        expect(base_model.active?).to eql(true)
      end

      it "has its status set to 'for_now'" do
        expect(base_model.status).to eql(Cart::FOR_NOW)
      end

      it "has has no cart items" do
        expect(base_model.cart_items.count).to eql(0)
      end
    end

    describe "inactive cart factory" do
      let(:inactive_cart) { create(:cart, :inactive)}

      it "is inactive" do
        expect(inactive_cart.active?).to eql(false)
      end
    end

    describe "cart for later factory" do
      let(:cart_for_later) { create(:cart, :for_later_bin)}

      it "has the status 'for_later'" do
        expect(cart_for_later.status).to eql(Cart::FOR_LATER)
      end
    end

    describe "paid_cart factory" do
      let(:paid_cart) { create(:cart, :paid)}

      it "has its status set to 'paid'" do
        expect(paid_cart.status).to eql(Cart::PAID)
      end
    end

    describe "awaiting_cheque cart factory" do
      let(:awaiting_cheque_cart) { create(:cart, :awaiting_cheque)}

      it "has its status set to 'paid'" do
        expect(awaiting_cheque_cart.status).to eql(Cart::AWAITING_CHEQUE)
      end
    end

    describe "cart with_basic_items factory" do
      let(:basic_items_cart) { create(:cart, :with_basic_items)}

      it "is valid" do
        expect(basic_items_cart).to be_valid
      end

      it "has at least one cart item" do
        expect(basic_items_cart.cart_items.count).to be > 0
      end

      it "has no items that are marked unavailable" do
        unavailable_seen = false
        basic_items_cart.cart_items.each { |i| unavailable_seen = true if i.available == false}
        expect(unavailable_seen).to eql(false)
      end

      it "has no items that are free" do
        free_seen = false
        basic_items_cart.cart_items.each { |i| free_seen = true if i.acquirable.price_cents == 0 }
        expect(free_seen).to eql(false)
      end

      it "has no items that are expired" do
        expired_seen = false
        basic_items_cart.cart_items.each { |i| expired_seen = true if i.acquirable.active? == false }
        expect(expired_seen).to eql(false)
      end

      it "has no items that are invalid" do
        invalid_seen = false
        basic_items_cart.cart_items.each { |i| invalid_seen = true if i.valid? == false }
        expect(invalid_seen).to eql(false)
      end

      it "has no items that have holdables" do
        holdable_seen = false
        basic_items_cart.cart_items.each { |i| holdable_seen = true if i.holdable.present? }
        expect(holdable_seen).to eql(false)
      end

      it "has no items where .kind == 'unknown' " do
        unknown_kind_seen = false
        basic_items_cart.cart_items.each { |i| unknown_kind_seen = true if i.kind == CartItem::UNKNOWN }
        expect(unknown_kind_seen).to eql(false)
      end
    end

    describe "cart with_free_items factory" do
      let(:free_only_cart) { create(:cart, :with_free_items)}

      it "is valid" do
        expect(free_only_cart).to be_valid
      end

      it "has at least one cart item" do
        expect(free_only_cart.cart_items.count).to be > 0
      end

      it "has no items that are not free" do
        not_free_seen = false
        free_only_cart.cart_items.each { |i| not_free_seen = true if i.acquirable.price_cents > 0 }
        expect(not_free_seen).to eql(false)
      end
    end

    describe "cart with_unavailable_items factory" do
      let(:unavailable_only_cart) { create(:cart, :with_unavailable_items)}

      it "is valid" do
        expect(unavailable_only_cart).to be_valid
      end

      it "has at least one cart item" do
        expect(unavailable_only_cart.cart_items.count).to be > 0
      end

      it "has no items that are marked available" do
        available_seen = false
        unavailable_only_cart.cart_items.each { |i| available_seen = true if i.available == true }

        expect(available_seen).to eql(false)
      end
    end

    describe "cart with_altered_price_items factory" do
      let(:cart_with_altered_price_items) { create(:cart, :with_altered_price_items)}

      it "is valid" do
        expect(cart_with_altered_price_items).to be_valid
      end

      it "has at least one cart item" do
        expect(cart_with_altered_price_items.cart_items.count).to be > 0
      end

      it "has no items where the item_price_memo field matches the acquirable's price_cents field" do
        match_seen = false
        cart_with_altered_price_items.cart_items.each { |i| match_seen = true if i.item_price_memo == i.acquirable.price_cents}
        expect(match_seen).to eql(false)
      end
    end

    describe "cart with_altered_name_items factory" do
      let(:cart_with_altered_name_items) { create(:cart, :with_altered_name_items)}

      it "is valid" do
        expect(cart_with_altered_name_items).to be_valid
      end

      it "has at least one cart item" do
        expect(cart_with_altered_name_items.cart_items.count).to be > 0
      end

      it "has no items where the item_name_memo field matches the acquirable's name field" do
        match_seen = false
        cart_with_altered_name_items.cart_items.each { |i| match_seen = true if i.item_name_memo == i.acquirable.name}
        expect(match_seen).to eql(false)
      end
    end

    describe "cart with_unknown_kind_items factory" do
      let(:cart_with_unknown_kind_items) { create(:cart, :with_unknown_kind_items)}

      it "is valid" do
        expect(cart_with_unknown_kind_items).to be_valid
      end

      it "has at least one cart item" do
        expect(cart_with_unknown_kind_items.cart_items.count).to be > 0
      end

      it "only has items where kind = 'unknown'" do
        known_seen = false
        cart_with_unknown_kind_items.cart_items.each { |i| known_seen = true if i.kind != CartItem::UNKNOWN }
        expect(known_seen).to eql(false)
      end
    end

    describe "cart with_expired_membership_items factory" do
      let(:expired_only_cart) { create(:cart, :with_expired_membership_items)}

      it "is valid" do
        expect(expired_only_cart).to be_valid
      end

      it "has at least one cart item" do
        expect(expired_only_cart.cart_items.count).to be > 0
      end

      it "has no items associated with unexpired memberships" do
        unexpired_seen = false
        expired_only_cart.cart_items.each { |i| unexpired_seen = true if i.acquirable.active? == true }
        expect(unexpired_seen).to eql(false)
      end
    end

    describe "cart_with_partially_paid_reservation_items factory" do
      let(:cart_with_partially_paid) { create(:cart, :with_partially_paid_reservation_items)}

      it "is valid" do
        expect(cart_with_partially_paid).to be_valid
      end

      it "has at least one cart item" do
        expect(cart_with_partially_paid.cart_items.count).to be > 0
      end

      it "contains only items that have recieved partial payment" do
        part_pd_holdable_seen = 0
        cart_with_partially_paid.cart_items.each { |i| part_pd_holdable_seen += 1 if (ReservationPaymentHistory.new(i.holdable).any_successful_charges? && (AmountOwedForReservation.new(i.holdable).amount_owed > 0)) }

        expect(part_pd_holdable_seen).to eql(cart_with_partially_paid.cart_items.count)
      end
    end

    describe "cart_with_paid_reservation_items factory" do
      let(:cart_with_paid) { create(:cart, :with_paid_reservation_items)}

      it "is valid" do
        expect(cart_with_paid).to be_valid
      end

      it "has at least one cart item" do
        expect(cart_with_paid.cart_items.count).to be > 0
      end

      it "contains only items that have recieved full payment" do
        fully_pd_holdable_seen = 0
        cart_with_paid.cart_items.each { |i| fully_pd_holdable_seen += 1 if (ReservationPaymentHistory.new(i.holdable).any_successful_charges? && (AmountOwedForReservation.new(i.holdable).amount_owed <= 0)) }

        expect(fully_pd_holdable_seen).to eql(cart_with_paid.cart_items.count)
      end
    end

    describe "cart_with_unpaid_reservation_items factory" do
      let(:cart_with_unpaid) { create(:cart, :with_unpaid_reservation_items)}

      it "is valid" do
        expect(cart_with_unpaid).to be_valid
      end

      it "has at least one cart item" do
        expect(cart_with_unpaid.cart_items.count).to be > 0
      end

      it "does not contain any cart_items without holdables" do
        missing_h = false
        cart_with_unpaid.cart_items.each {|i| missing_h = true if i.holdable.blank?}

        expect(missing_h).to eql(false)
      end

      it "does not contain any cart_items with holdables that have charges" do
        holdable_charge_seen = false

        cart_with_unpaid.cart_items.each { |i| holdable_charge_seen = true if i.holdable.charges.present? }

        expect(holdable_charge_seen).to eql(false)
      end
    end

    describe "cart fully_paid_through_direct_charges" do
      let(:cart_fully_pd_direct) { create(:cart, :fully_paid_through_direct_charges)}

      it "is valid" do
        expect(cart_fully_pd_direct).to be_valid
      end

      it "has at least one cart item" do
        expect(cart_fully_pd_direct.cart_items.count).to be > 0
      end

      it "has at least one successful charge" do
        expect(cart_fully_pd_direct.charges.successful.count).to be > 0
      end

      it "has the same number of charges and cart_items" do
        expect(cart_fully_pd_direct.cart_items.count).to eql(cart_fully_pd_direct.charges.count)
      end

      it "contains no cart_items that have successful charges" do

        scsfl_item_charge_seen = false

        cart_fully_pd_direct.cart_items.each { |i| scsfl_item_charge_seen = true if (i.holdable.present? && i.holdable.charges.present? && i.holdable.charges.successful.present?) }

        expect(scsfl_item_charge_seen).to eql(false)
      end

      it "has successful charges that equal the combined price of the cart-items" do
        successful_cart_charges = cart_fully_pd_direct.successful_direct_charge_total

        combined_cart_item_price = cart_fully_pd_direct.cart_items.sum{ |i| i.acquirable.price_cents }

        expect(successful_cart_charges).to eql(combined_cart_item_price)
      end
    end

    describe "cart partially_paid_through_direct_charges" do
      let(:cart_part_pd_direct) { create(:cart, :partially_paid_through_direct_charges)}

      it "is valid" do
        expect(cart_part_pd_direct).to be_valid
      end

      it "has at least one cart item" do
        expect(cart_part_pd_direct.cart_items.count).to be > 0
      end

      it "has no cart_items with successful charges" do
        successful_cart_charge_seen = 0

        cart_part_pd_direct.cart_items.each do |i|
          if i.holdable.present? && i.holdable.charges.present? && i.holdable.charges.successful.present?
            successful_cart_charge_seen += i.holdable.successful_direct_charge_total
          end
        end

        expect(successful_cart_charge_seen).to eql(0)
      end

      it "has at least one successful direct charge" do
        expect(cart_part_pd_direct.charges.successful.count).to be > 0
      end

      it "has successful direct charges that, in total, are less than the combined price of the cart_items" do
        successful_cart_charges = cart_part_pd_direct.charges.successful.present? ? cart_part_pd_direct.charges.successful.sum(:amount_cents) : 0

        combined_cart_item_price = cart_part_pd_direct.cart_items.sum(&:price_cents)

        expect(successful_cart_charges).to be < combined_cart_item_price
      end
    end

    describe "cart fully_paid_through_direct_charge_and_paid_item_combo" do
      let(:cart_fully_pd_combo) { create(:cart, :fully_paid_through_direct_charge_and_paid_item_combo)}

      it "is valid" do
        expect(cart_fully_pd_combo).to be_valid
      end

      it "has at least one cart item" do
        expect(cart_fully_pd_combo.cart_items.count).to be > 0
      end

      it "has at least one cart item with a successful charge" do
        successful_seen = false

        cart_fully_pd_combo.cart_items.each do |i|
          successful_seen = true if (i.holdable.present? && i.holdable.successful_direct_charges?)
        end

        expect(successful_seen).to eql(true)
      end

      it "has at least one successful direct charge" do
        expect(cart_fully_pd_combo.successful_direct_charges?).to eql(true)
      end

      it "has successful direct charges and successful cart_item charges that, combined, equal the total price of the cart_items" do
        successful_cart_charges = cart_fully_pd_combo.successful_direct_charge_total

        successful_cart_item_charges = cart_fully_pd_combo.cart_items.sum{|i| i.holdable.present? ? i.holdable.successful_direct_charge_total : 0 }

        combined_cart_item_price = cart_fully_pd_combo.cart_items.sum(&:price_cents)

        expect(successful_cart_charges + successful_cart_item_charges).to eql(combined_cart_item_price)
      end
    end

    describe "cart partially_paid_through_direct_charge_and_paid_item_combo" do
      let(:cart_part_pd_combo) { create(:cart, :partially_paid_through_direct_charge_and_paid_item_combo)}

      it "is valid" do
        expect(cart_part_pd_combo).to be_valid
      end

      it "has at least one cart item" do
        expect(cart_part_pd_combo.cart_items.count).to be > 0
      end

      it "has at least one cart item with a successful charge" do
        successful_c_seen = false

        cart_part_pd_combo.cart_items.each do |i|
          successful_c_seen = true if i.holdable.present? && i.holdable.charges.present? && i.holdable.charges.successful.present?
        end

        expect(successful_c_seen).to eql(true)
      end

      it "has at least one successful direct charge" do
        expect(cart_part_pd_combo.charges.successful.count).to be > 0
      end

      it "has successful direct charges and successful cart_item charges that, combined, are less than the total price of the cart_items" do
        successful_cart_charges = cart_part_pd_combo.successful_direct_charge_total

        successful_cart_item_charges = cart_part_pd_combo.cart_items.sum{|i| i.holdable.present? ? i.holdable.successful_direct_charge_total : 0 }

        combined_cart_item_price = cart_part_pd_combo.cart_items.sum(&:price_cents)

        expect(successful_cart_charges + successful_cart_item_charges).to be < combined_cart_item_price
      end
    end
  end

  describe "associations" do
    it "belongs to User" do
      expect(base_model).to belong_to(:user)
    end

    it "has many CartItems" do
      expect(base_model).to have_many(:cart_items)
    end

    it "has many charges" do
      expect(base_model).to have_many(:charges)
    end
  end

  describe "attributes" do
    it "Has the attribute 'status' with a base value of 'for_now'" do
      expect(base_model).to have_attributes(:status => Cart::FOR_NOW)
    end
  end

  describe "validations" do
    describe "validation of 'status'" do
      it "validates the presence of the 'status' attribute" do
        expect(base_model).to validate_presence_of(:status)
      end

      it "will not allow 'status' to accept the Boolean value true" do
        expect(base_model).not_to allow_value(true).for(:status)
      end

      it "will not allow 'status' to accept the integer value 4" do
        expect(base_model).not_to allow_value(4).for(:status)
      end

      it "will not allow 'status' accept the value 'haggis'" do
        expect(base_model).not_to allow_value('haggis').for(:status)
      end

      it "WILL allow 'status' to accept the value 'paid'" do
        expect(base_model).to allow_value(Cart::PAID).for(:status)
      end

      it "WILL allow 'status' to accept the value 'for_later'" do
        expect(base_model).to allow_value(Cart::FOR_LATER).for(:status)
      end

      it "WILL allow 'status' to accept the value 'for_now'" do
        expect(base_model).to allow_value(Cart::FOR_NOW).for(:status)
      end

      it "WILL allow 'status' to accept the value 'for_later'" do
        expect(base_model).to allow_value(Cart::AWAITING_CHEQUE).for(:status)
      end
    end

    describe "validation of 'User'" do
      let(:starting_cart) { create(:cart)}
      let(:validation_cart) { create(:cart)}

      context "when the cart's status is 'for_now' " do
        context "when the cart's scope is 'active'" do
          before do
            validation_cart.update_attribute(:user, starting_cart.user)
          end

          it "Validates user's uniquenesss" do
            expect(validation_cart.user).to eql(starting_cart.user)
            validation_cart.valid?
            expect(validation_cart).not_to be_valid
          end
        end

        context "when the cart's scope is 'inactive'" do
          before do
            starting_cart.update_attribute(:active_to, 1.day.ago)
            validation_cart.update_attribute(:active_to, 1.day.ago)
            validation_cart.update_attribute(:user, starting_cart.user)
          end

          it "Doesn't validate User's uniqueness" do
            expect(validation_cart.user).to eql(starting_cart.user)
            validation_cart.valid?
            expect(validation_cart).to be_valid
          end
        end
      end

      context "when cart's status is 'for_later'" do
        before do
          starting_cart.update_attribute(:status, Cart::FOR_LATER)
          validation_cart.update_attribute(:status, Cart::FOR_LATER)
        end

        context "when the cart's scope is 'active'" do
          before do
            validation_cart.update_attribute(:user, starting_cart.user)
          end

          it "Validates User's uniqueness" do
            expect(validation_cart.user).to eql(starting_cart.user)
            validation_cart.valid?
            expect(validation_cart).not_to be_valid
          end
        end

        context "when the cart's scope is 'inactive'" do
          before do
            starting_cart.update_attribute(:active_to, 1.day.ago)
            validation_cart.update_attribute(:active_to, 1.day.ago)
            validation_cart.update_attribute(:user, starting_cart.user)
          end

          it "Doesn't validate User's uniqueness" do
            expect(validation_cart.user).to eql(starting_cart.user)
            validation_cart.valid?
            expect(validation_cart).to be_valid
          end
        end
      end

      context "when the cart's status is 'awaiting_cheque' " do
        before do
          starting_cart.update_attribute(:status, Cart::AWAITING_CHEQUE)
          validation_cart.update_attribute(:status, Cart::AWAITING_CHEQUE)
          validation_cart.update_attribute(:user, starting_cart.user)
        end

        it "Doesn't validate User's uniqueness" do
          expect(validation_cart.user).to eql(starting_cart.user)
          validation_cart.valid?
          expect(validation_cart).to be_valid
        end
      end

      context "when cart's status is 'paid'" do
        before do
          starting_cart.update_attribute(:status, Cart::PAID)
          validation_cart.update_attribute(:status, Cart::PAID)
          validation_cart.update_attribute(:user, starting_cart.user)
        end

        it "Doesn't validate User's uniqueness" do
          expect(validation_cart.user).to eql(starting_cart.user)
          validation_cart.valid?
          expect(validation_cart).to be_valid
        end
      end
    end
  end

  describe "public instance methods" do
    describe "#cart_items_raw_price_cents_combined" do
      context "empty cart" do
        it "returns an integer" do
          expect(base_model.subtotal_cents).to be_kind_of(Integer)
        end

        it "returns zero" do
          expect(base_model.subtotal_cents).to eql(0)
        end
      end

      context "cart with basic items" do
        let(:basic_items_cart) { create(:cart, :with_basic_items)}

        it "returns an integer" do
          expect(basic_items_cart.subtotal_cents).to be_kind_of(Integer)
        end

        it "returns a value greater than zero" do
          expect(basic_items_cart.subtotal_cents).to be > 0
        end

        it "returns the sum of the prices of all the CartItems' Acquirables" do
          cart_subtotal = basic_items_cart.cart_items.inject(0) { |s, i| s + i.acquirable.price_cents }
          expect(cart_subtotal).to eql(basic_items_cart.subtotal_cents)
        end

        it "returns the same value as a call to 'subtotal_cents'" do
          expect(basic_items_cart.cart_items_raw_price_cents_combined).to eql(basic_items_cart.subtotal_cents)
        end
      end

      context "cart with partially paid reservation items" do
        let(:part_paid_items_cart) { create(:cart, :with_partially_paid_reservation_items)}

        it "returns an integer" do
          expect(part_paid_items_cart.cart_items_raw_price_cents_combined).to be_kind_of(Integer)
        end

        it "returns a value greater than zero" do
          expect(part_paid_items_cart.cart_items_raw_price_cents_combined).to be > 0
        end

        it "returns the sum of the prices of all the CartItems' Acquirables" do
          cart_subtotal = part_paid_items_cart.cart_items.inject(0) { |s, i| s + i.acquirable.price_cents }
          expect(cart_subtotal).to eql(part_paid_items_cart.cart_items_raw_price_cents_combined)
        end

        it "returns a value greater than that of a call to 'subtotal_cents'" do
          expect(part_paid_items_cart.cart_items_raw_price_cents_combined).to be > part_paid_items_cart.subtotal_cents
        end
      end

      context "cart with fully paid reservation items" do
        let(:fully_paid_items_cart) { create(:cart, :with_paid_reservation_items)}
        it "returns an integer" do
          expect(fully_paid_items_cart.cart_items_raw_price_cents_combined).to be_kind_of(Integer)
        end

        it "returns a value greater than zero" do
          expect(fully_paid_items_cart.cart_items_raw_price_cents_combined).to be > 0
        end

        it "returns the sum of the prices of all the CartItems' Acquirables" do
          cart_subtotal = fully_paid_items_cart.cart_items.inject(0) { |s, i| s + i.acquirable.price_cents }
          expect(cart_subtotal).to eql(fully_paid_items_cart.cart_items_raw_price_cents_combined)
        end

        it "returns a value greater than that of a call to 'subtotal_cents'" do
          expect(fully_paid_items_cart.cart_items_raw_price_cents_combined).to be > fully_paid_items_cart.subtotal_cents
        end
      end
    end

    describe "#subtotal_cents" do
      context "empty cart" do
        it "returns an integer" do
          expect(base_model.subtotal_cents).to be_kind_of(Integer)
        end

        it "returns zero" do
          expect(base_model.subtotal_cents).to eql(0)
        end
      end

      context "cart with basic items" do
        let(:basic_items_cart) { create(:cart, :with_basic_items)}

        it "returns an integer" do
          expect(basic_items_cart.subtotal_cents).to be_kind_of(Integer)
        end

        it "returns a value greater than zero" do
          expect(basic_items_cart.subtotal_cents).to be > 0
        end

        it "returns the sum of the prices of all the CartItems' Acquirables" do
          cart_subtotal = basic_items_cart.cart_items.sum(&:price_cents)
          expect(cart_subtotal).to eql(basic_items_cart.subtotal_cents)
        end
      end

      context "cart with paid reservation items" do
        let(:paid_reservation_cart) { create(:cart, :with_paid_reservation_items)}

        it "returns an integer" do
          expect(paid_reservation_cart.subtotal_cents).to be_kind_of(Integer)
        end

        it "returns zero" do
          expect(paid_reservation_cart.subtotal_cents).to eql(0)
        end

        it "returns an amount less than the sum of the CartItems' acquirables" do
          cart_acquirable_subtotal = paid_reservation_cart.cart_items.sum(&:price_cents)
          expect(paid_reservation_cart.subtotal_cents).to be < cart_acquirable_subtotal
        end

        it "returns the sum of the amounts owing on each item" do
          cart_total_due = 0
          paid_reservation_cart.cart_items.each do |i|
            cart_total_due += AmountOwedForReservation.new(i.holdable).amount_owed.cents
          end

          expect(paid_reservation_cart.subtotal_cents).to eql(cart_total_due)
        end
      end

      context "cart with partially paid reservation items" do
        let(:part_paid_reservation_cart) { create(:cart, :with_partially_paid_reservation_items)}

        it "returns an integer" do
          expect(part_paid_reservation_cart.subtotal_cents).to be_kind_of(Integer)
        end

        it "returns a value greater than zero" do
          expect(part_paid_reservation_cart.subtotal_cents).to be > 0
        end

        it "returns an amount less than the sum of the CartItems' Acquirables' prices" do
          cart_acquirable_subtotal = part_paid_reservation_cart.cart_items.sum(&:price_cents)
          expect(part_paid_reservation_cart.subtotal_cents).to be < cart_acquirable_subtotal
        end

        it "returns the sum of the amounts owing on each item" do
          cart_total_due = 0

          part_paid_reservation_cart.cart_items.each do |i|
            cart_total_due += AmountOwedForReservation.new(i.holdable).amount_owed.cents
          end

          expect(part_paid_reservation_cart.subtotal_cents).to eql(cart_total_due)
        end
      end
    end

    describe "#subtotal_display" do
      context "empty cart" do
        let(:empty_cart) { create(:cart)}

        it "returns a string" do
          expect(empty_cart.subtotal_display).to be_kind_of(String)
        end

        it "does not show a value over $0.00" do
          expect(empty_cart.subtotal_display).not_to match(/[1-9]/)
        end

        it "is expressed in US dollars with an explicit unit abbreviation" do
          expect(empty_cart.subtotal_display).to match(/\A\${1}\d{1,3}(?:,\d{3})*\.{1}\d{2}\sUSD\z/)
        end
      end

      context "cart with basic items" do
        let(:basic_items_cart) { create(:cart, :with_basic_items)}

        it "returns a string" do
          expect(basic_items_cart.subtotal_display).to be_kind_of(String)
        end

        it "Shows a value over $0.00" do
          expect(basic_items_cart.subtotal_display).to match(/[1-9]/)
        end

        it "is expressed in US dollars with an explicit unit abbreviation" do
          # This isn't bulletproof as a currency format validator, but it's more than good enough for the current purpose.
          expect(basic_items_cart.subtotal_display).to match(/\A\${1}\d{1,3}(?:,\d{3})*\.{1}\d{2}\sUSD\z/)
        end
      end

      describe "#items_paid?" do
        context "empty cart" do
          it "returns true" do
            expect(base_model.items_paid?).to eql(true)
          end
        end

        context "when the cart has no successful charges of its own" do
          context "when the cart_items have no successful charges of their own" do
            let(:basic_cart) { create(:cart, :with_basic_items)}

            it "returns false" do
              expect(basic_cart.items_paid?).to eql(false)
            end
          end

          context "when the cart_items are partially paid with charges of their own" do
            let(:part_paid_items_cart) {create(:cart, :with_partially_paid_reservation_items)}

            it "returns false" do
              expect(part_paid_items_cart.items_paid?).to eql(false)
            end
          end

          context "when the cart_items are fully paid with charges of their own" do
            let(:fully_paid_items_cart) {create(:cart, :with_paid_reservation_items)}

            it "returns true" do
              expect(fully_paid_items_cart.items_paid?).to eql(true)
            end
          end
        end

        context "when the cart has successful charges of its own" do
          context "when the cart_items have no charges of their own" do
            context "when the cart's succesful direct charges equal the price of the cart_items" do
              let(:full_pd_dir_cart) {create(:cart, :fully_paid_through_direct_charges)}

              it "returns true" do
                expect(full_pd_dir_cart.items_paid?).to eql(false)
              end
            end
          end
        end

        context "when the cart_items have successful charges of their own" do
          context "when the cart's successful direct charges, combined with the successful charges of the cart_items, equals the combined price of the cart_items" do
            let(:full_combo_cart) {create(:cart, :fully_paid_through_direct_charge_and_paid_item_combo)}

            it "returns true" do
              expect(full_combo_cart.items_paid?).to eql(false)
            end
          end
        end
      end

      describe "#cents_owed_for_cart_less_all_credits" do
        context "empty cart" do
          it "returns an integer" do
            expect(base_model.cents_owed_for_cart_less_all_credits).to be_a_kind_of(Integer)
          end

          it "returns zero" do
            expect(base_model.cents_owed_for_cart_less_all_credits).to eql(0)
          end
        end

        context "when the cart has no successful charges of its own" do
          context "when the cart_items have no successful charges of their own" do
            let(:basic_cart) { create(:cart, :with_basic_items)}

            it "returns an integer" do
              expect(basic_cart.cents_owed_for_cart_less_all_credits).to be_a_kind_of(Integer)
            end

            it "returns the combined price of the cart_items in cents" do
              cart_item_comb_price = basic_cart.cart_items.sum(&:price_cents)
              expect(basic_cart.cents_owed_for_cart_less_all_credits).to eql(cart_item_comb_price)
            end
          end

          context "when the cart_items are partially paid with charges of their own" do
            let(:part_paid_items_cart) {create(:cart, :with_partially_paid_reservation_items)}

            it "returns an integer" do
              expect(part_paid_items_cart.cents_owed_for_cart_less_all_credits).to be_a_kind_of(Integer)
            end

            it "returns the combined price of the cart_items in cents, less the sum of the cart_items' successful charges" do
              cart_item_comb_price = part_paid_items_cart.cart_items.sum(&:price_cents)

              cart_item_comb_succ_charges = part_paid_items_cart.cart_items.sum{|i| i.holdable.present? ? i.holdable.successful_direct_charge_total : 0 }

              expect(part_paid_items_cart.cents_owed_for_cart_less_all_credits).to eql(cart_item_comb_price - cart_item_comb_succ_charges)
            end
          end
        end

        context "when the cart has successful charges of its own" do
          context "when the cart_items have no charges of their own" do
            let(:part_pd_dir_cart) {create(:cart, :partially_paid_through_direct_charges)}

            it "returns an integer" do
              expect(part_pd_dir_cart.cents_owed_for_cart_less_all_credits).to be_a_kind_of(Integer)
            end

            it "returns the combined price of the cart_items in cents, less the sum of the cart's successful charges" do
              cart_item_comb_price = part_pd_dir_cart.cart_items.sum(&:price_cents)

              cart_successful_charges = (part_pd_dir_cart.charges.present? && part_pd_dir_cart.charges.successful.present?) ? part_pd_dir_cart.charges.sum(:amount_cents) : 0

              expect(part_pd_dir_cart.cents_owed_for_cart_less_all_credits).to eql(cart_item_comb_price - cart_successful_charges)
            end
          end

          context "when the cart_items have successful charges of their own" do
            let(:full_combo_cart) {create(:cart, :fully_paid_through_direct_charge_and_paid_item_combo)}

            it "returns an integer" do
              expect(full_combo_cart.cents_owed_for_cart_less_all_credits).to be_a_kind_of(Integer)
            end

            it "returns the combined price of the cart_items in cents, less the sum of the cart's successful charges, and less the sum of the cart_items' succesful charges" do
              cart_item_comb_price = full_combo_cart.cart_items.sum(&:price_cents)

              cart_item_success_ch = full_combo_cart.cart_items.sum{|i| i.holdable.present? ? i.holdable.successful_direct_charge_total : 0 }

              cart_success_ch = full_combo_cart.successful_direct_charge_total
              expect(full_combo_cart.cents_owed_for_cart_less_all_credits).to eql(cart_item_comb_price - cart_success_ch - cart_item_success_ch)
            end
          end
        end
      end
      describe "#active_and_for_later" do
        context "when the cart's status is 'for_now'" do
          context "when the cart is active" do
            it "returns true" do
              expect(base_model.active_and_for_later).to eql(false)
            end
          end

          context "when the cart is inactive" do
            let(:inactive_cart) {create(:cart, :inactive)}
            it "returns false" do
              expect(inactive_cart.active_and_for_later).to eql(false)
            end
          end
        end

        context "when the cart's status is 'awaiting_cheque'" do
          context "when the cart is active" do
            let(:active_cheque_cart) { create(:cart, :awaiting_cheque)}
            it "returns false" do
              expect(active_cheque_cart.active_and_for_later).to eql(false)
            end
          end

          context "when the cart is inactive" do
            let(:inactive_cheque_cart) {create(:cart, :inactive, :awaiting_cheque)}
            it "returns false" do
              expect(inactive_cheque_cart.active_and_for_later).to eql(false)
            end
          end
        end

        context "when the cart's status is 'paid'" do
          context "when the cart is active" do
            let(:active_paid_cart) { create(:cart, :paid)}
            it "returns false" do
              expect(active_paid_cart.active_and_for_later).to eql(false)
            end
          end

          context "when the cart is inactive" do
            let(:inactive_paid_cart) {create(:cart, :inactive, :paid)}
            it "returns false" do
              expect(inactive_paid_cart.active_and_for_later).to eql(false)
            end
          end
        end

        context "when the cart's status is 'for_later'" do
          context "when the cart is active" do
            let(:active_later_cart) { create(:cart, :for_later_bin)}
            it "returns false" do
              expect(active_later_cart.active_and_for_later).to eql(true)
            end
          end

          context "when the cart is inactive" do
            let(:inactive_later_cart) {create(:cart, :inactive, :for_later_bin)}
            it "returns false" do
              expect(inactive_later_cart.active_and_for_later).to eql(false)
            end
          end
        end
      end

      describe "#active_and_for_now" do
        context "when the cart's status is 'for_now'" do
          context "when the cart is active" do
            it "returns true" do
              expect(base_model.active_and_for_now).to eql(true)
            end
          end

          context "when the cart is inactive" do
            let(:inactive_cart) {create(:cart, :inactive)}
            it "returns false" do
              expect(inactive_cart.active_and_for_now).to eql(false)
            end
          end
        end

        context "when the cart's status is 'awaiting_cheque'" do
          context "when the cart is active" do
            let(:active_cheque_cart) { create(:cart, :awaiting_cheque)}
            it "returns false" do
              expect(active_cheque_cart.active_and_for_now).to eql(false)
            end
          end

          context "when the cart is inactive" do
            let(:inactive_cheque_cart) {create(:cart, :inactive, :awaiting_cheque)}
            it "returns false" do
              expect(inactive_cheque_cart.active_and_for_now).to eql(false)
            end
          end
        end

        context "when the cart's status is 'paid'" do
          context "when the cart is active" do
            let(:active_paid_cart) { create(:cart, :paid)}
            it "returns false" do
              expect(active_paid_cart.active_and_for_now).to eql(false)
            end
          end

          context "when the cart is inactive" do
            let(:inactive_paid_cart) {create(:cart, :inactive, :paid)}
            it "returns false" do
              expect(inactive_paid_cart.active_and_for_now).to eql(false)
            end
          end
        end

        context "when the cart's status is 'for_later'" do
          context "when the cart is active" do
            let(:active_later_cart) { create(:cart, :for_later_bin)}
            it "returns false" do
              expect(active_later_cart.active_and_for_now).to eql(false)
            end
          end

          context "when the cart is inactive" do
            let(:inactive_later_cart) {create(:cart, :inactive, :for_later_bin)}
            it "returns false" do
              expect(inactive_later_cart.active_and_for_now).to eql(false)
            end
          end
        end
      end
    end
  end
end
