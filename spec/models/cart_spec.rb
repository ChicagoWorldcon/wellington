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

  let(:empty_cart) { create(:cart)}
  let(:basic_items_cart) { create(:cart, :with_basic_items)}

  let(:saved_only_cart) { create(:cart, :with_items_for_later)}
  let(:for_now_and_saved_cart) { create(:cart, :with_basic_items, :with_items_for_later)}

  let(:unavailable_only_cart) { create(:cart, :with_unavailable_items)}
  let(:available_and_unavailable_cart) { create(:cart, :with_basic_items, :with_unavailable_items)}

  let(:free_only_cart) { create(:cart, :with_free_items)}
  let(:free_and_not_free_cart) { create(:cart, :with_basic_items, :with_free_items )}

  let(:incomplete_only_cart) {create(:cart, :with_incomplete_items)}
  let(:incomplete_and_complete_cart) {create(:cart, :with_incomplete_items, :with_basic_items)}

  let(:expired_only_cart) { create(:cart, :with_expired_membership_items)}
  let(:expired_and_unexpired_cart) { create(:cart, :with_basic_items, :with_expired_membership_items)}

  let!(:cart_with_all_problem_items) { create(:cart, :with_all_problematic_items)}

  let!(:cart_with_100_mixed) { create(:cart, :with_100_mixed_items)}

  describe "#factories" do
    it "can create a valid, basic object" do
      expect(create(:cart)).to be_valid
    end

    describe "empty cart factory" do
      it "is valid" do
        expect(empty_cart).to be_valid
      end
      it "has no cart items" do
        expect(empty_cart.cart_items.count).to eql(0)
      end
    end

    describe "cart with_basic_items factory" do
      it "is valid" do
        expect(basic_items_cart).to be_valid
      end

      it "has at least one cart item" do
        expect(basic_items_cart.cart_items.count).to be > 0
      end

      it "has no items that are saved for later" do
        saved_for_later_seen = false
        basic_items_cart.cart_items.each { |i| saved_for_later_seen = true if i.later == true }
        expect(saved_for_later_seen).to eql(false)
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
    end

    describe "cart with_items_for_later factory" do
      it "is valid" do
        expect(saved_only_cart).to be_valid
      end

      it "has at least one cart item" do
        expect(saved_only_cart.cart_items.count).to be > 0
      end

      it "has no items that are not saved for later" do
        for_now_seen = false
        saved_only_cart.cart_items.each { |i| for_now_seen = true if i.later == false }
        expect(for_now_seen).to eql(false)
      end
    end

    describe "cart with_free_items factory" do
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

    describe "cart with_expired_membership_items factory" do
      it "is valid" do
        expect(expired_only_cart).to be_valid
      end

      it "has at least one cart item" do
        expect(expired_only_cart.cart_items.count).to be > 0
      end

      it "has no items for unexpired memberships" do
        unexpired_seen = false
        expired_only_cart.cart_items.each { |i| unexpired_seen = true if i.acquirable.active? == true }
        expect(unexpired_seen).to eql(false)
      end
    end

    describe "cart with_incomplete_items factory" do
      it "is valid" do
        expect(incomplete_only_cart).to be_valid
      end

      it "has at least one cart item" do
        expect(incomplete_only_cart.cart_items.count).to be > 0
      end

      it "has no items that are not marked incomplete" do
        complete_seen = false
        incomplete_only_cart.cart_items.each { |i| complete_seen = true if !i.incomplete}
        expect(complete_seen).to eql(false)
      end
    end

    describe "all_problematic_items factory" do
      it "is valid" do
        expect(cart_with_all_problem_items).to be_valid
      end

      it "Has a bunch of stuff going on" do
        pending
      end
    end

    describe "cart with_100_mixed factory" do
      it "is valid" do
        expect(cart_with_100_mixed).to be_valid
      end

      it "has 100 cart-items" do
        expect(cart_with_100_mixed.cart_items.count).to eql(100)
      end

      it "has 15 items marked as unavailable" do
        unavailable_seen = 0
        cart_with_100_mixed.cart_items.each { |i| unavailable_seen += 1 if !i.available}
        expect(unavailable_seen).to eql(15)
      end

      it "has 15 free items" do
        free_seen = 0
        cart_with_100_mixed.cart_items.each { |i| free_seen += 1 if i.acquirable.price_cents == 0 }
        expect(free_seen).to eql(15)
      end

      it "has 15 expired items" do
        expired_seen = 0
        cart_with_100_mixed.cart_items.each {|i| expired_seen += 1 if i.acquirable.active? == false}
        expect(expired_seen).to eql(15)
      end

      it "has 15 saved-for-later items" do
        later_seen = 0
        cart_with_100_mixed.cart_items.each {|i|
          later_seen += 1 if i.later}
        expect(later_seen).to eql(15)
      end

      it "has 15 incomplete items" do
        incomplete_seen = 0
        cart_with_100_mixed.cart_items.each {|i|
          incomplete_seen += 1 if i.incomplete}
        expect(incomplete_seen).to eql(15)
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
  end

  describe "attributes" do
    describe "status" do
      let(:naive_cart) { create(:cart)}
      it "has a default status of 'pending'" do
        expect(naive_cart).to have_attributes(:status => "pending")
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
        it "returns an integer" do
          expect(basic_items_cart.subtotal_cents).to be_kind_of(Integer)
        end

        it "returns a value greater than zero" do
          expect(basic_items_cart.subtotal_cents).to be > 0
        end

        it "returns the sum of the prices of all its cart_items" do
          cart_subtotal = 0
          basic_items_cart.cart_items.each {|i| cart_subtotal += i.acquirable.price_cents}
          expect(cart_subtotal).to eql(basic_items_cart.subtotal_cents)
        end
      end

      context "cart with mixed for-now and saved-for-later items" do
        it "returns the sum of the prices of all cart items that are not saved for later" do
          cart_subtotal = 0
          for_now_and_saved_cart.cart_items.each {|i| cart_subtotal += i.acquirable.price_cents if !i.later}
          expect(cart_subtotal).to eql(for_now_and_saved_cart.subtotal_cents)
        end
      end

      context "cart with mixed available and unavailable items" do
        it "returns the sum of the prices of all cart items that are not marked unavailable" do
          cart_subtotal = 0
          available_and_unavailable_cart.cart_items.each {|i| cart_subtotal += i.acquirable.price_cents if i.available}
          expect(cart_subtotal).to eql(available_and_unavailable_cart.subtotal_cents)
        end
      end

      context "cart with mixed expired and unexpired items" do
        it "returns the sum of the prices of all cart items that are not expired" do
          cart_subtotal = 0
          expired_and_unexpired_cart.cart_items.each {|i| cart_subtotal += i.acquirable.price_cents if i.acquirable.active?}
          expect(cart_subtotal).to eql(expired_and_unexpired_cart.subtotal_cents)
        end
      end

      context "cart with free items" do
        it "returns zero" do
          expect(free_only_cart.subtotal_cents).to eql(0)
        end
      end
    end

    describe "subtotal_display" do
      context "empty cart" do
        it "returns a string" do
          expect(empty_cart.subtotal_display).to be_kind_of(String)
        end

        it "does not show a value over $0.00" do
          expect(empty_cart.subtotal_display).not_to match(/[1-9]/)
        end

        it "is expressed in US dollars" do
          expect(empty_cart.subtotal_display).to match(/\A\${1}\d+.{1}\d{2}\z/)
        end
      end

      context "cart with basic items" do
        it "returns a string" do
          expect(basic_items_cart.subtotal_display).to be_kind_of(String)
        end

        it "Shows a value over $0.00" do
          expect(basic_items_cart.subtotal_display).to match(/[1-9]/)
        end

        it "is expressed in US dollars" do
          # This isn't bulletproof as a currency format validator, but it's more than good enough for the current purpose.
          expect(basic_items_cart.subtotal_display).to match(/\A\${1}[0-9,]+.{1}\d{2}\z/)
        end
      end
    end

    describe "items_for_now" do
      context "empty cart" do
        it "is empty" do
          expect(empty_cart.items_for_now).to be_empty
        end
      end

      context "cart with mixed items-for-now and saved-for-later items" do
        it "is not empty" do
          expect(for_now_and_saved_cart.items_for_now).not_to be_empty
        end

        it "contains instances of CartItem" do
          expect(for_now_and_saved_cart.items_for_now.sample()).to be_kind_of(CartItem)
        end

        it "contains no items that are marked as saved for later" do
          later_seen = false
          for_now_and_saved_cart.items_for_now.each {|i| later_seen = true if i.later == true}
          expect(later_seen).to eql(false)
        end
      end

      context "cart with unavailable items" do
        it "is not empty" do
          expect(unavailable_only_cart.items_for_now).not_to be_empty
        end

        it "contains an a number of items equal to the total number of cart items" do
          expect(unavailable_only_cart.items_for_now.count).to eql(unavailable_only_cart.cart_items.count)
        end
      end

      context "cart with expired items" do
        it "is not empty" do
          expect(expired_only_cart.items_for_now).not_to be_empty
        end

        it "contains an a number of items equal to the total number of cart items" do
          expect(expired_only_cart.items_for_now.count).to eql(expired_only_cart.cart_items.count)
        end
      end
    end

    describe "items_for_later" do
      context "empty cart" do
        it "is empty" do
          expect(empty_cart.items_for_later).to be_empty
        end
      end

      context "cart with basic items" do
        it "is empty" do
          expect(basic_items_cart.items_for_later).to be_empty
        end
      end

      context "cart with only items for later" do
        it "is not empty" do
          expect(saved_only_cart.items_for_later).not_to be_empty
        end

        it "contains instances of CartItem" do
          expect(saved_only_cart.items_for_later.sample()).to be_kind_of(CartItem)
        end

        it "contains a number of items equal to the total number of CartItems" do
          expect(saved_only_cart.items_for_later.count).to eql(saved_only_cart.cart_items.count)
        end
      end

      context "cart with mixture of items for now and items saved for later" do
        it "is not empty" do
          expect(for_now_and_saved_cart.items_for_later).not_to be_empty
        end

        it "contains no cart items that are not marked as saved for later" do
          for_now_seen = false
          for_now_and_saved_cart.items_for_later.each {|i| for_now_seen = true if i.later == false}
          expect(for_now_seen).to eql(false)
        end
      end
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
        expect(base_model).to allow_value('paid').for(:status)
      end
    end
  end
end
