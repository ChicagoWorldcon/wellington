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
      let(:inactive_cart) { create(:cart)}

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
        expect(awaiting_cheque_cart.status).to eql(Cart::PAID)
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
        expect(part_pd_holdable_seen).to eql(cart_with_partially_paid.cart_items.count)
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

      it "contains only items that have recieved full payment" do
        unpd_holdable_seen = 0
        cart_with_unpaid.cart_items.each { |i| unpd_holdable_seen += 1 if (ReservationPaymentHistory.new(i.holdable).any_successful_charges? == false && (AmountOwedForReservation.new(i.holdable).amount_owed < i.acquirable.price_cents)) }
        expect(unpd_holdable_seen).to eql(cart_with_unpaid.cart_items.count)
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

      it "WILL allow 'status' to accept the value 'for_later'" do
        expect(base_model).to allow_value(Cart::FOR_NOW).for(:status)
      end

      it "WILL allow 'status' to accept the value 'for_later'" do
        expect(base_model).to allow_value(Cart::AWAITING_CHEQUE).for(:status)
      end
    end
  end

  describe "public instance methods" do
    describe "subtotal_cents" do
      context "empty cart" do

        it "returns an integer" do
          expect(empty_cart.subtotal_cents).to be_kind_of(Integer)
        end

        it "returns zero" do
          expect(empty_cart.subtotal_cents).to eql(0)
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
          cart_subtotal = basic_items_cart.cart_items.inject { |s, i| s + i.acquirable.price_cents }
          expect(cart_subtotal).to eql(basic_items_cart.subtotal_cents)
        end
      end

      context "cart with free items" do
        let(:free_cart) { create(:cart, :with_free_items)}

        it "returns an integer" do
          expect(free_cart.subtotal_cents).to be_kind_of(Integer)
        end

        it "returns zero" do
          expect(free_cart.subtotal_cents).to eql(0)
        end

        it "returns the sum of the prices of all the CartItems' Acquirables" do
          cart_subtotal = free_cart.cart_items.inject { |s, i| s + i.acquirable.price_cents }
          expect(cart_subtotal).to eql(free_items_cart.subtotal_cents)
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
          cart_acquirable_subtotal = paid_reservation_cart.cart_items.inject { |s, i| s + i.acquirable.price_cents }
          expect(paid_reservation_cart.subtotal_cents).to be < cart_acquirable_subtotal
        end

        it "returns the sum of the amounts owing on each item" do
          cart_total_due = 0
          paid_reservation_cart.cart_items.each do |i|
            cart_total_due += AmountOwedForReservation.new(i.holdable).amount_owed
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
          cart_acquirable_subtotal = part_paid_reservation_cart.cart_items.inject { |s, i| s + i.acquirable.price_cents }
          expect(part_paid_reservation_cart.subtotal_cents).to be < cart_acquirable_subtotal
        end

        it "returns the sum of the amounts owing on each item" do
          cart_total_due = 0

          paid_reservation_cart.cart_items.each do |i|
            cart_total_due += AmountOwedForReservation.new(i.holdable).amount_owed
          end

          expect(paid_reservation_cart.subtotal_cents).to eql(cart_total_due)
        end
      end
    end

    describe "subtotal_display" do
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

      describe "paid?" do
        context "empty cart" do
          let(:empty_cart) { create(:cart)}

          it "returns a string" do
            expect(empty_cart.paid).to be_kind_of(Numeric)
          end

          it "does not show a value over $0.00" do
            expect(empty_cart.subtotal_display).not_to match(/[1-9]/)
          end

          it "is expressed in US dollars with an explicit unit abbreviation" do
            expect(empty_cart.subtotal_display).to match(/\A\${1}\d{1,3}(?:,\d{3})*\.{1}\d{2}\sUSD\z/)
          end
        end

        context "empty cart" do
          let(:basic_cart) { create(:cart)}

          it "returns a string" do
            expect(empty_cart.paid?).to be_falsey
          end

          it "does not show a value over $12.00" do
            expect(empty_cart.subtotal_display).not_to match(/[1-9]/)
          end

          it "is expressed in US dollars with an explicit unit abbreviation" do
            expect(empty_cart.subtotal_display).to match(/\A\${1}\d{1,3}(?:,\d{3})*\.{1}\d{2}\sUSD\z/)
          end
        end
      end
    end
  end
end
