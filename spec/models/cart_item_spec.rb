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
      expect(create(:cart_item)).to be_valid
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
      :uknown_kind,
      :nonmembership_without_benefitable
    ].each do |factory_trait|
      it "can create a valid object with trait:  #{factory_trait}" do
        expect(create(:cart_item, factory_trait)).to be_valid
      end
    end
  end

  describe "associations" do
    it "belongs to 'acquirable'" do
      expect(base_model).to belong_to(:acquirable)
    end

    it "belongs to 'benefitable'" do
      # This is tested without_validating_presence here because it is conditionally
      # validated with a proc. That validation will be tested below.
      expect(base_model).to belong_to(:benefitable).without_validating_presence
    end

    it "belongs to 'cart'" do
      expect(base_model).to belong_to(:cart)
    end
  end

  describe "attributes" do
    let(:naive) {create(:cart_item)}

    it "Has the attribute 'available' with a default value of true and the attribute 'later' with a default value of false" do
      expect(naive).to have_attributes(:available => true, :later => false)
    end
  end

  describe "callbacks" do

    describe "before_validation: note_acquirable_details if: :new_record?" do
      context "new record" do
        let(:callback_item_1) {build(:cart_item)}
        let(:callback_item_2) {build(:cart_item)}

        it "Has a nil value for item_name_memo and a value of zero for item_price_memo and until after validation" do
          expect(callback_item_1.item_price_memo).to eql(0)
          expect(callback_item_1.item_name_memo).to be_nil
          callback_item_1.save
          expect(callback_item_1.item_price_memo).to be > 0
          expect(callback_item_1.item_name_memo).not_to be_nil
        end

        it "Has values for item_price_memo and item_name_memo that match its acquirable's price_cents and name attributes after saving" do
          expect(callback_item_2.item_price_memo).to eql(0)
          expect(callback_item_2.item_name_memo).to be_nil
          callback_item_2.save
          expect(callback_item_2.item_name_memo).to eql(callback_item_2.acquirable.name)
          expect(callback_item_2.item_price_memo).to eql(callback_item_2.acquirable.price_cents)
        end
      end

      context "persisted record" do
        # Make a new, naive CartItem
        let(:callback_item_3) {create(:cart_item, :with_ya)}
        # Create a new Acquirable, which will be assigned to the CartItem during testing.
        let(:new_acquirable) {create(:membership, :adult)}

        it "does not have its item_name_memo and item_price_memo attributes automatically updated on save" do
          # Document original CartItem values.
          original_name_memo = callback_item_3.item_name_memo
          original_price_memo = callback_item_3.item_price_memo
          original_acquirable_id = callback_item_3.acquirable_id

          # Assign the new acquirable.
          callback_item_3.update_attribute(:acquirable, new_acquirable)
          # Demonstrate that the new acquirable has successfully associated.
          expect(callback_item_3.acquirable_id).to eql(new_acquirable.id)
          if original_acquirable_id != new_acquirable.id
            expect(callback_item_3.acquirable_id).to_not eql(original_acquirable_id)
          end
          #Show that the item_name_memo will keep its original value, rather than taking on that of the new acquirable
          expect(callback_item_3.item_name_memo).to eql(original_name_memo)
          expect(callback_item_3.item_name_memo).not_to eql(new_acquirable.name)
          #And the same will happen for item_price_memo.
          expect(callback_item_3.item_price_memo).to eql(original_price_memo)
          expect(callback_item_3.item_price_memo).not_to eql(new_acquirable.price_cents)
        end
      end
    end
  end

  describe "public instance methods" do
    describe "item_display_name" do
      let(:display_name_item) {create(:cart_item)}
      it "does not equal 'unknown' when CartItem.kind == 'membership'" do
        # Arrangement:
        display_name_item.update_attribute(:kind, "membership")
        # Test validation:
        expect(display_name_item.kind).to eql("membership")
        # Actual test
        expect(display_name_item.item_display_name).not_to eql("unknown")
      end
      it "equals 'unknown' when the CartItem.kind != 'membership'" do
        #Arrangement:
        display_name_item.update_attribute(:kind, "unknown")
        #Test validation:
        expect(display_name_item.kind).to eql("unknown")
        # Actual test
        expect(display_name_item.item_display_name).to be == "unknown"
      end
    end

    describe "item_display_price" do
      let(:display_price_item) {create(:cart_item, kind: "membership")}

      it "is a string" do
        expect(base_model.item_display_price).to be_kind_of(String)
      end

      it "does not show a nonzero value when the CartItem.kind == 'unknown'" do
        # Arrangement:
        display_price_item.update_attribute(:kind, "unknown")
        #Test validation:
        expect(display_price_item.kind).to eql("unknown")
        #Actual test:
        expect(display_price_item.item_display_price).not_to match(/[1-9]/)
      end

      it "Shows a nonzero value when CartItem.kind == 'membership' and its acquirable has a positive value" do
        # Arrangement:
        display_price_item.update_attribute(:kind, "membership")
        #Test validations:
        expect(display_price_item.kind).to eql("membership")
        expect(display_price_item.acquirable.price_cents).to be > 0
        #Actual test:
        expect(display_price_item.item_price_memo).to be > 0
        expect(display_price_item.item_display_price).to match(/[1-9]/)
      end


    end

    # describe "item_beneficiary_name" do
    #   let(:beneficiary_name_item) {create(:cart_item)}
    #   context "when kind == 'membership'" do
    #
    #     beneficiary_name_item.update_attributes!(kind: "membership")
    #     expect(:beneficiary_name_item.kind).to eql("membership")
    #
    #     it "matches its benefitable's display_name_for_cart" do
    #       expect(:beneficiary_name_item.item_beneficiary_name).to eql(:beneficiary_name_item.benefitable.name_for_cart)
    #     end
    #   end
    #
    #   context "when kind != 'membership'" do
    #     beneficiary_name_item.update_attributes!(kind: "unknown")
    #     expect(:beneficiary_name_item.kind).to eql("unknown")
    #
    #     it "is an empty string" do
    #       expect(:beneficiary_name_item.item_beneficiary_name).to eql("")
    #     end
    #   end
    # end

    # describe "item_still_available?" do
    #   let(:availability_item) {create(:cart_item)}
    #   let(:availalability_item_2) { create(:cart_item, :with_supporting)}
    #   let(:availablitity_item_3) {create(:cart_item, :with_ya)}
    #
    #   let(:expired_membership_item1) {create(:cart_item, :with_expired_membership_tuatara)}
    #   let(:expired_membership_item2) {create(:cart_item, :with_expired_membership_silver_f)}
    #
    #   context "when available == false" do
    #     it "returns false, even if it would otherwise return true." do
    #       # Arrangement for test validation:
    #       availability_item.update_attributes!(available: true)
    #       # Test Validation:
    #       expect(:availability_item.item_still_available?).to eql(true)
    #
    #       # Arrangement for actual test:
    #       availability_item.update_attributes!(available: false)
    #       # Actual test:
    #       expect(:availability_item.item_still_available?).to eql(false)
    #     end
    #   end

      # context "when its acquirable has expired" do
      #
      #   #test validations:  Already-expired memberships
      #   expect(:expired_membership_item_1.acquirable.active?).to eql(false)
      #   expect(:expired_membership_item_2.acquirable.active?).to eql(false)
      #
      #   #test validations: acquirable artificially expired:
      #   expect(:availablitity_item_3.acquirable.active?).to eql(true)
      #   availability_item_3.acquirable.update_attributes(active_to: 1.day.ago)
      #   expect(availability_item_3.acquirable.active?).to eql(false)
      #   expect(availability_item_3.available).to eql(true)
      #
      #   it "returns false" do
      #     expect(:expired_membership_item1.item_still_available?).to eql(false)
      #
      #     expect(:availability_item_3.item_still_available?).to eql(false)
      #   end
      #
      #   it "sets its own 'available' attribute to false" do
      #     # Validation
      #     expect(:expired_membership_item_2.available).to eql(true)
      #     # Action
      #     expired_membership_item2.item_still_available?
      #     # Actual test
      #     expect(:expired_membership_item2.available).to eql(true)
      #   end
      # end
      #
      # context "when its item_name_memo doesn't match its aquirable's name" do
      #   let(:name_match_item) {create(:cart_item:)}
      #   #test_validation
      #   expect(:name_match_item.item_still_available?).to eql(true)
      #   it "returns false, even if it would have returned true if the names had matched." do
      #     expect(:name_match_item.item_name_memo).to eql(:name_match_item.acquirable.name)
      #     expect(:name_match_item.item_still_available?).to eql(true)
      #     name_match_item.update_attributes!(item_name_memo: "altered")
      #     expect(:name_match_item.item_name_memo).to_not eql(:name_match_item.acquirable.name)
      #     expect(:name_match_item.item_still_available?).to eql(false)
      #   end
      # end
      #
      # context "when its item_price_memo doesn't match its aquirable's price_cents" do
      #   let(:price_match_item) {create(:cart_item:)}
      #   #test_validation
      #   expect(:price_match_item.item_still_available?).to eql(true)
      #   it "returns false, even if it would have returned true if the names had matched." do
      #     expect(:price_match_item.item_price_memo).to eql(:price_match_item.acquirable.price_cents)
      #     expect(:price_match_item.item_still_available?).to eql(true)
      #     price_match_item.update_attributes!(item_price_memo: :price_match_item.acquirable.price_cents + 30)
      #     expect(:price_match_item.item_price_memo).to_not eql(:price_match_item.acquirable.price_cents)
      #     expect(:price_match_item.item_still_available?).to eql(false)
      #   end
      #
      # end
      #
      # context "when its display name is unknown" do
      #   let(:failed_display_item) { create(:cart_item)}
      #   #Test validations:
      #   it "Even when it would otherwise return true, a display name of 'unknown' will cause it to return false" do
      #     expect(:failed_display_item.item_display_name).not_to eql("unknown")
      #     expect(:failed_display_item.item_still_available?).to eql(true)
      #     failed_display_item.update_attributes!(kind: "unknown")
      #     expect(:failed_display_item.item_display_name).to eql("unknown")
      #     expect(:failed_display_item.item_still_available?).to eql(false)
      #   end
      # end
    end





  #
  # describe "validations" do
  #
  #   describe "validation of 'acquirable'" do
  #     it "Validates the presence of the 'acquirable' attribute" do
  #       expect(base_model).to_not allow_nil(:acquirable)
  #     end
  #   end
  #
  #   describe "validation of 'available'" do
  #     it "validates the presence of the 'available' attribute" do
  #       expect(base_model).to validate_presence_of(:available)
  #     end
  #
  #     it "will not allow 'available' to equal 'heck, yeah'" do
  #       expect(base_model).to_not allow_value("heck, yeah").for(:available)
  #     end
  #
  #     it "WILL allow 'available' to equal false" do
  #       expect(base_model).to allow_value(false).for(:available)
  #     end
  #   end
  #
  #   describe "validation of 'benefitable'" do
  #     it "Validates the presence of 'benefitable' when the value of 'kind' is 'membership'" do
  #       let(:membership_item) {create(:cart_item, kind: "membership")}
  #       expect(membership_item).to_not allow_nil(:benefitable)
  #     end
  #
  #     it "Allows the 'benefitable' attribute to be nil when the value of 'kind' is 'nonmembership'" do
  #       let(:nonmembership_item) {create(:cart_item, kind: "nonmembership" )}
  #       expect(nonmembership_item).to allow_nil(:benefitable)
  #     end
  #   end
  #
  #   describe "validation of 'item_name_memo'" do
  #     it "validates the presence of the 'item_name_memo' attribute" do
  #       expect(base_model).to validate_presence_of(:item_name_memo)
  #     end
  #   end
  #
  #   describe "validation of 'item_price_memo'" do
  #     it "validates the presence of the 'item_price_memo' attribute" do
  #       it "validates the presence of the 'item_price_memo' attribute" do
  #         expect(base_model).to validate_presence_of(:item_price_memo)
  #       end
  #     end
  #
  #     it "validates 'item_price_memo' as numerical" do
  #       expect(base_model).to validate_numericality_of(:item_price_memo)
  #     end
  #   end
  #
  #   describe "validation of 'kind'" do
  #     it "validates the presence of the 'kind' attribute" do
  #       expect(base_model).to validate_presence_of(:kind)
  #     end
  #
  #     it "will not allow 'kind' to accept the Boolean value true" do
  #       expect(base_model).to_not allow_value(true).for(:kind)
  #     end
  #
  #     it "will not allow 'kind' to accept the integer value 7" do
  #       expect(base_model).to_not allow_value(7).for(:kind)
  #     end
  #
  #     it "will not allow 'kind' accept the value 'meatloaf'" do
  #       expect(base_model).to_not allow_value('meatloaf').for(:kind)
  #     end
  #
  #     it "WILL allow 'kind' to accept the value 'membership'" do
  #       expect(base_model).to allow_value('membership').for(:kind)
  #     end
  #
  #     it "WILL allow 'kind' to accept the value 'unknown'" do
  #       expect(base_model).to allow_value('unknown').for(:kind)
  #     end
  #   end
  #
  #   describe "validation of 'later'" do
  #     it "validates the presence of the 'later' attribute" do
  #       expect(base_model).to validate_presence_of(:later)
  #     end
  #
  #     it "will not allow 'later' to accept the integer value 8" do
  #       expect(base_model).to_not allow_value(8).for(:later)
  #     end
  #
  #     it "will not allow 'later' to accept the value 'alligator'" do
  #       expect(base_model).to_not allow_value('alligator').for(:later)
  #     end
  #
  #     it "WILL allow 'later' to accept the Boolean value false" do
  #       expect(base_model).to allow_value(false).for(:later)
  #     end
  #   end
  # end
  #

  #

  #

  # end
end
