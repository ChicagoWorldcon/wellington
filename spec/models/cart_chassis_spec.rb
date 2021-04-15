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
    context "basic factory" do

      let(:basic_chassis) { build(:cart_chassis)}

      it "can create a valid, basic object" do
        expect(basic_chassis).to be
        expect(basic_chassis).to be_kind_of(CartChassis)
      end

      it "has now_bin and later_bin attributes that are both Carts" do
        expect(basic_chassis.now_bin).not_to be_nil
        expect(basic_chassis.now_bin).to be_kind_of(Cart)
        expect(basic_chassis.now_bin.status).to eql("for_now")

        expect(basic_chassis.later_bin).not_to be_nil
        expect(basic_chassis.later_bin).to be_kind_of(Cart)
        expect(basic_chassis.now_bin.status).to eql("for_later")
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

    xdescribe "#verify_avil_for_saved_items" do
      pending
    end

    xdescribe "#verify_avil_for_all_items" do
      pending
    end

    xdescribe "#can_proceed_to_payment" do
      pending
    end

    xdescribe "#payment_by_check_allowed?" do
      pending
    end
  end
end
