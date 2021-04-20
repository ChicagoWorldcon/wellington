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
  end

  xdescribe "public instance methods" do
    xdescribe "#full_reload" do
      pending
    end

    xdescribe "#now_items" do
      pending
    end

    xdescribe "#later_items" do
      pending
    end

    xdescribe "#user" do
      pending
    end

    xdescribe "#purchase_bin" do
      pending
    end

    xdescribe "#purchase_bin_paid?" do
      pending
    end

    xdescribe "#purchase_subtotal_cents" do
      pending
    end

    xdescribe "#items_to_purchase_count" do
      pending
    end

    xdescribe "#blank_out_purchase_bin" do
      pending
    end

    xdescribe "#move_item_to_saved" do
      pending
    end

    xdescribe "#move_item_to_cart" do
      pending
    end

    xdescribe "#save_all_items_for_later" do
      pending
    end

    xdescribe "#move_all_saved_to_cart" do
      pending
    end

    xdescribe "#destroy_all_items_for_now" do
      pending
    end

    xdescribe "#destroy_all_items_for_later" do
      pending
    end

    xdescribe "#destroy_all_cart_contents" do
      pending
    end

    xdescribe "#now_items_count" do
      pending
    end

    xdescribe "#later_items_count" do
      pending
    end

    xdescribe "#all_items_count" do
      pending
    end

    xdescribe "#verify_avail_for_items_for_now" do
      pending
    end

    xdescribe "#verify_avail_for_saved_items" do
      pending
    end

    xdescribe "#verify_avail_for_all_items" do
      pending
    end

    xdescribe "#can_proceed_to_payment?" do
      pending
    end

    xdescribe "#payment_by_check_allowed?" do
      pending
    end
  end
end
