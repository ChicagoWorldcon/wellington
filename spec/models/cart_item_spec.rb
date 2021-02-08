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

RSpec.describe CartItem, type: :model do

  subject(:base_model) {create(:cart_item)}

  describe "#factories" do

    it "can create a valid, basic object" do
      expect(create(:cart_item).to be_valid
    end

    [
      :with_kidit,
      :with_ya,
      :with_supporting,
      :with_expired_membership_tuatara,
      :with_expired_membership_silver_f,
      :saved_for_later,
      :unavailable,
      :price_altered,
      :name_altered,
      :unknown_kind,
      :nonmembership
    ].each do |factory_with_trait|
      it "can create a valid object with trait:  #{factory_trait}" do
        expect(create(:cart_item, factory_trait)).to be_valid
      end
    end
  end

  describe "attributes" do
    it "Has the attribute 'available' with a default value of true and the attribute 'later' with a default value of false" do
      expect(base_model.later).to have_attributes(:available => true, :later => false)
    end
  end

  describe "validations" do

    describe "validation of 'acquirable'" do
      it "Validates the presence of the 'acquirable' attribute" do
        expect(base_model).to_not allow_nil(:acquirable)
      end
    end

    describe "validation of 'available'" do
      it "validates the presence of the 'available' attribute" do
        expect(base_model).to validate_presence_of(:available)
      end

      it "will not allow 'available' to equal 'heck, yeah'" do
        expect(base_model).to_not allow_value("heck, yeah").for(:available)
      end

      it "WILL allow 'available' to equal false" do
        expect(base_model).to allow_value(false).for(:available)
      end
    end

    describe "validation of 'benefitable'" do
      it "Validates the presence of 'benefitable' when the value of 'kind' is 'membership'" do
        let(:membership_item) {create(:cart_item, kind: "membership")}
        expect(membership_item).to_not allow_nil(:benefitable)
      end

      it "Allows the 'benefitable' attribute to be nil when the value of 'kind' is 'nonmembership'" do
        let(:nonmembership_item) {create(:cart_item, kind: "nonmembership")}
        expect(nonmembership_item).to allow_nil(:benefitable)
      end
    end

    describe "validation of 'item_name'" do
      it "validates the presence of the 'item_name' attribute" do
        expect(base_model).to validate_presence_of(:item_name)
      end
    end

    describe "validation of 'item_price_cents'" do
      it "validates the presence of the 'item_price_cents' attribute" do
        it "validates the presence of the 'item_name' attribute" do
          expect(base_model).to validate_presence_of(:item_price_cents)
        end
      end

      it "validates 'item_price_cents' as numerical" do
        expect(base_model).to validate_numericality_of(:item_price_cents)
      end

      it "monetizes 'item_price_cents'" do
        expect(base_model).to monetize(:item_price_cents)
      end
    end

    describe "validation of 'kind'" do
      it "validates the presence of the 'kind' attribute" do
        expect(base_model).to validate_presence_of(:kind)
      end

      it "will not allow 'kind' to accept the Boolean value true" do
        expect(base_model).to_not allow_value(true).for(:kind)
      end

      it "will not allow 'kind' accept the value 'meatloaf'" do
        expect(base_model).to_not allow_value('meatloaf').for(:kind)
      end

      it "WILL allow 'kind' to accept the value 'membership'" do
        expect(base_model).to allow_value('membership').for(:kind)
      end

      it "WILL allow 'kind' to accept the value 'nonmembership'" do
        expect(base_model).to allow_value('nonmembership').for(:kind)
      end
    end

    describe "validation of 'later'" do
      it "validates the presence of the 'later' attribute" do
        expect(base_model).to validate_presence_of(:later)
      end

      it "will not allow 'later' to accept the value 'alligator'" do
        expect(base_model).to_not allow_value('alligator').for(:later)
      end

      it "WILL allow 'later' to accept the Boolean value false" do
        expect(base_model).to allow_value(false).for(:later)
      end
    end
  end

  describe "associations" do

    describe "'acquirable' association" do
      expect(base_model).to belong_to(:acquirable)
    end

    describe "'benefitable' association" do
      expect(base_model).to belong_to(:benefitable)
    end

    describe "'cart' association" do
      expect(base_model).to belong_to(:cart)
    end
  end

  describe "public instance methods" do
    let(:instance_method_item) {create(:cart_item, kind: "membership")}
    describe "item_display_name" do
      it "does not equal 'unknown' when CartItem.kind == 'membership'" do
        expect(instance_method_item.item_display_name).not_to be == "unknown"
      end
      it "equals 'unknown' when the CartItem.kind == 'membership'" do
        instance_method_item.update_attribute(:kind, "unknown")
        expect(disp_name_item.item_display_name).to be == "unknown"
      end
    end

    describe "item_monetized_price" do
      let(:mon_price_item) {create(:cart_item, kind: "membership")}
      it "is numerical" do
        expect(base_model.item_monetized_price).to be_kind_of(Numeric)
      end
      it "does not equal zero when CartItem.kind == 'membership' and its acquirable has a positive value" do

        # TODO: FINISH THIS


        instance_method_item.update_attribute(:kind, "unknown")
        expect(instance_method_item.item_monetized_price).not_to be == 0
      end
      it "equals 'unknown' when the CartItem.kind == 'membership'" do
        disp_name_item.update_attribute(:kind, "unknown")
        expect(disp_name_item.item_display_name).to be == "unknown"
      end

    end

    describe "item_display_price" do

    end



    describe "item_beneficiary_name" do

    end

    describe "item_still_available?" do

    end
  end
end
