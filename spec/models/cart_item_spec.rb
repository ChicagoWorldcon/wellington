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

    [ :with_free_membership,
      :with_expired_membership,
      :with_partially_paid_reservation,
      :with_unpaid_reservation,
      :with_paid_reservation,
      :unavailable,
      :price_altered,
      :name_altered,
      :unknown_kind,
      :nonmembership_without_benefitable
    ].each do |factory_trait|
      it "can create a valid object with trait:  #{factory_trait}" do
        expect(create(:cart_item, factory_trait)).to be_valid
      end
    end

    describe "basic CartItem factory outputs" do
      it "is a CartItem" do
        expect(base_model).to be_an_instance_of(CartItem)
      end

      it "is marked available" do
        expect(base_model.available).to eql(true)
      end

      it "has a value for 'kind' that is not 'unknown'" do
        expect(base_model.kind).to be_truthy
        expect(base_model.kind).not_to eql(CartItem::UNKNOWN)
      end

      it "does not have a holdable" do
        expect(base_model.holdable).not_to be
      end

      it "has a valid acquirable" do
        expect(base_model.acquirable).to be_valid
      end

      it "has an acquirable that is not free" do
        expect(base_model.acquirable.price_cents).to be > 0
      end

      it "has an acquirable that is not expired" do
        expect(base_model.acquirable.active?).to eql(true)
      end

      it "has a string value for its 'item_name_memo' attribute that matches its acquirable's name" do
        expect(base_model.item_name_memo).to be_an_instance_of(String)
        strings_match = base_model.item_name_memo.eql?(base_model.acquirable.name)
        expect(strings_match).to eql(true)
      end

      it "has a value for its 'item_price_memo' attribute that does not match its acquirable's price" do
        price_difference = base_model.item_price_memo - base_model.acquirable.price_cents

        expect(price_difference).to eql(0)
      end

      it "has a benefitable" do
        expect(base_model.benefitable).to be
      end
    end

    describe "factory outputs :with_free_membership" do
      let(:free_cart_item) { create(:cart_item, :with_free_membership)}

      it "has an acquirable that is free" do
        expect(free_cart_item.acquirable).to be
        expect(free_cart_item.acquirable.price_cents).to eql(0)
      end

      it "has an acquirable that is not expired" do
        expect(free_cart_item.acquirable.active?).to eql(true)
      end
    end

    describe "factory outputs :with_expired_membership" do
      let(:expired_cart_item) { create(:cart_item, :with_expired_membership)}

      it "has an acquirable that is not free" do
        expect(expired_cart_item.acquirable).to be
        expect(expired_cart_item.acquirable.price_cents).to be > 0
      end

      it "has an acquirable that is expired" do
        expect(expired_cart_item.acquirable.active?).to eql(false)
      end
    end

    describe "factory outputs :with_partially_paid_reservation" do
      let(:partially_paid_cart_item) { create(:cart_item, :with_partially_paid_reservation)}

      it "has a holdable, and that holdable has at least one charge" do
        expect(partially_paid_cart_item.holdable).to be
        expect(partially_paid_cart_item.holdable.charges.count).to be > 0
      end

      it "has an acquirable that is not free" do
        expect(partially_paid_cart_item.acquirable).to be
        expect(partially_paid_cart_item.acquirable.price_cents).to be > 0
      end

      it "has a holdable with successful charges that, cumulatively, are less than its acquirable's price" do
        successful_charges_tally = 0
        partially_paid_cart_item.holdable.charges.each {|i| successful_charges_tally += i.amount_cents if i.successful?}

        expect(successful_charges_tally).to be > 0
        expect(partially_paid_cart_item.acquirable.price_cents).to be > successful_charges_tally
      end
    end

    describe "factory outputs :with_unpaid_reservation" do
      let(:unpaid_cart_item) { create(:cart_item, :with_unpaid_reservation)}

      it "has a holdable, and that holdable has no charges" do
        expect(unpaid_cart_item.holdable).to be
        expect(unpaid_cart_item.holdable.charges.blank?).to eql(true)
      end

      it "has an acquirable that is not free" do
        expect(unpaid_cart_item.acquirable).to be
        expect(unpaid_cart_item.acquirable.price_cents).to be > 0
      end
    end

    describe "factory outputs :with_paid_reservation" do
      let(:paid_cart_item) { create(:cart_item, :with_paid_reservation)}

      it "has a holdable, and that holdable has at least one charge" do
        expect(paid_cart_item.holdable).to be
        expect(paid_cart_item.holdable.charges.count).to be > 0
      end

      it "has an acquirable that is not free" do
        expect(paid_cart_item.acquirable).to be
        expect(paid_cart_item.acquirable.price_cents).to be > 0
      end

      it "has a holdable with successful charges that, cumulatively, are at least equal to the acquirable's price" do
        successful_charges_tally = 0
        paid_cart_item.holdable.charges.each {|i| successful_charges_tally += i.amount_cents if i.successful?}

        expect(successful_charges_tally).to be > 0
        expect(paid_cart_item.acquirable.price_cents).to be >= successful_charges_tally
      end
    end

    describe "factory outputs :unavailable" do
      let(:unavailable_cart_item) { create(:cart_item, :unavailable)}

      it "has its 'available' attribute set to false" do
        expect(unavailable_cart_item.available).to eql(false)
      end
    end

    describe "factory outputs :price_altered" do
      let(:price_altered_cart_item) { create(:cart_item, :price_altered)}

      it "has a value for its 'item_price_memo' attribute that does not match its acquirable's price" do
        price_difference = price_altered_cart_item.item_price_memo - price_altered_cart_item.acquirable.price_cents

        expect(price_difference.abs).to be > 0
      end
    end

    describe "factory outputs :name_altered" do
      let(:name_altered_cart_item) { create(:cart_item, :name_altered)}

      it "has a string value for its 'item_name_memo' attribute that does not match its acquirable's name" do
        expect(name_altered_cart_item.item_name_memo).to be_an_instance_of(String)
        strings_match = name_altered_cart_item.item_name_memo.eql?(name_altered_cart_item.acquirable.name)
        expect(strings_match).to eql(false)
      end
    end

    describe "factory outputs :unknown_kind" do
      let(:unknown_kind_cart_item) { create(:cart_item, :unknown_kind)}

      it "has its 'kind' attribute set to 'unknown'" do
        expect(unknown_kind_cart_item.kind).to eql(CartItem::UNKNOWN)
      end
    end

    describe "factory outputs :nonmembership_without_benefitable" do
      let(:nonmem_noben_cart_item) { create(:cart_item, :nonmembership_without_benefitable)}

      it "does not have a benefitable" do
        expect(nonmem_noben_cart_item.benefitable).not_to be
      end

      it "has its 'kind' attribute set to 'unknown'" do
        expect(nonmem_noben_cart_item.kind).to eql(CartItem::UNKNOWN)
      end
    end
  end

  describe "associations" do
    let(:item_with_holdable) { create(:cart_item, :with_paid_reservation)}

    it "belongs to 'acquirable'" do
      expect(base_model).to belong_to(:acquirable)
    end

    it "belongs to 'holdable'" do
      expect(item_with_holdable).to belong_to(:holdable)
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
    it "Has the attribute 'available' with a default value of true" do
      expect(base_model).to have_attributes(:available => true)
    end

    it "Has the attribute 'kind' which matches the type of its acquirable" do
      expect(base_model.kind.downcase).to eql(base_model.acquirable_type.downcase)
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
        let(:callback_item_3) {create(:cart_item, :with_expired_membership)}
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
    describe "#item_display_name" do
      it "does not equal 'unknown' when CartItem.kind == 'membership'" do
        # Arrangement:
        base_model.update_attribute(:kind, "membership")
        # Test validation:
        expect(base_model.kind).to eql("membership")
        # Actual test
        expect(base_model.item_display_name).not_to eql("unknown")
      end

      it "equals 'unknown' when the CartItem.kind != 'membership'" do
        #Arrangement:
        base_model.update_attribute(:kind, "unknown")
        #Test validation:
        expect(base_model.kind).to eql("unknown")
        # Actual test
        expect(base_model.item_display_name).to be == "unknown"
      end
    end

    describe "item_unique_id_for_laypeople" do

      let(:uniq_item_with_res) {create(:cart_item, :with_unpaid_reservation)}
      let(:uniq_item_without_res) {create(:cart_item)}

      context "When the CartItem is a Membership item associated with a reservation" do
        it "Is equal to the reservation's membership number" do
          # Test validations:
          expect(uniq_item_with_res.holdable).to be
          expect(uniq_item_with_res.kind).to eql(CartItem::MEMBERSHIP)
          expect(uniq_item_with_res.acquirable).to be_an_instance_of(Membership)

          # Actual test
          expect(uniq_item_with_res.item_unique_id_for_laypeople).not_to be_nil
          expect(uniq_item_with_res.item_unique_id_for_laypeople).to be_kind_of(Numeric)
          expect(uniq_item_with_res.item_unique_id_for_laypeople).to eql(uniq_item_with_res.holdable.membership_number)
        end
      end

      context "When the CartItem is a Membership item not associated with a reservation" do
        it "Is nil" do
          # Test validation:
          expect(uniq_item_without_res.kind).to eql(CartItem::MEMBERSHIP)
          expect(uniq_item_without_res.acquirable).to be_an_instance_of(Membership)
          expect(uniq_item_without_res.holdable).not_to be
          # Actual test
          expect(uniq_item_with_res.item_unique_id_for_laypeople).not_to be_nil
        end
      end

      context "When the CartItem has an unknown kind, but it associated with a reservation" do
        it "Is nil" do
          # Arrangement:
          uniq_item_with_res.update_attribute(:kind, "unknown")
          # Test validation:
          expect(uniq_item_with_res.kind).to eql("unknown")
          expect(uniq_item_with_res.holdable).to be
          # Actual test
          expect(uniq_item_with_res.item_unique_id_for_laypeople).to be_nil
        end
      end
    end

    describe "quick_description" do

      it "Is a string" do
        expect(base_model.quick_description).to be_a_kind_of(String)
      end

      it "Has a number of characters equal to the length of its item's display name, kind, and shortened beneficiary name, plus five" do
        expected_length = (
          base_model.item_display_name.length + base_model.kind.length + base_model.shortened_item_beneficiary_name.length + 6)

        expect(base_model.quick_description.length).to eql(expected_length)
      end

      it "Has a length that varies when the length of the elements that compose it vary" do

        binding.pry
        og_quick_desc_length = base_model.quick_description.length
        og_kind_length = base_model.kind.length

        binding.pry
        new_kind = String.new(base_model.kind + base_model.kind + base_model.kind)
        base_model.update_attribute(:kind, new_kind)

        binding.pry
        expect(base_model.kind).to eql(new_kind)
        expect(base_model.kind.length - og_kind_length).to eql(base_model.quick_description.length - og_quick_desc_length)
      end
    end

    describe "item_display_price" do
      it "is a string" do
        expect(base_model.item_display_price).to be_kind_of(String)
      end

      it "does not show a nonzero value when the CartItem.kind == 'unknown'" do
        # Arrangement:
        base_model.update_attribute(:kind, CartItem::UNKNOWN)
        #Test validation:
        expect(base_model.kind).to eql(CartItem::UNKNOWN)
        #Actual test:
        expect(base_model.item_display_price).not_to match(/[1-9]/)
      end

      it "Shows a nonzero value when CartItem.kind == 'membership' and its acquirable has a positive value" do
        #Test validations:
        expect(base_model.kind).to eql(CartItem::MEMBERSHIP)
        expect(base_model.acquirable.price_cents).to be > 0
        #Actual test:
        expect(base_model.item_price_memo).to be > 0
        expect(base_model.item_display_price).to match(/[1-9]/)
      end
    end

    describe "item_price_in_cents" do

      context "When the item has an unknown kind" do
        it "equals zero" do
          base_model.update_attribute(:kind, CartItem::UNKNOWN)

          expect(base_model.kind).to eql(CartItem::UNKNOWN)
          expect(base_model.item_price_in_cents).to be_kind_of(Numeric)
          expect(base_model.item_price_in_cents).to eql(0)
        end
      end

      context "When the item is a membership without a reservation" do
        it "equals the price of the membership" do

          #Test Validation
          expect(base_model.kind).to eql(CartItem::MEMBERSHIP)
          expect(base_model.holdable).not_to be

          expect(base_model.item_price_in_cents).to be_kind_of(Integer)
          expect(base_model.item_price_in_cents).to eql(base_model.acquirable.price_cents)
        end
      end

      context "When the item has a reservation with a payment" do
        let(:part_paid_item) {create(:cart_item, :with_partially_paid_reservation)}

        it "equals the amount left owing on the membership" do
          #Test Validations
          expect(part_paid_item.item_price_in_cents).to be_kind_of(Integer)
          expect(part_paid_item.item_price_in_cents).to be < part_paid_item.acquirable.price_in_cents_for_cart

          successful_charge_tally = 0
          part_paid_item.holdable.charges.each {|c| successful_charge_tally += c.amount_cents if c.state == Charge::STATE_SUCCESSFUL}

          expect(part_paid_item.item_price_in_cents).to eql(part_paid_item.acquirable.price_cents - successful_charge_tally)
        end
      end
    end

    describe "item_beneficiary_name" do
    #let(:beneficiary_name_item) {create(:cart_item)}
      context "when kind == 'membership'" do

        it "matches its benefitable's display_name_for_cart" do
          #Test Validations
          expect(base_model.acquirable).to be_an_instance_of(Membership)
          expect(base_model.kind).to eql("membership")
          #Actual Test:
          expect(base_model.item_beneficiary_name).to eql(base_model.benefitable.name_for_cart)
        end
      end

      context "when kind != 'membership'" do
        it "is an empty string" do
          base_model.update_attribute(:kind, "unknown")
          expect(base_model.kind).to eql("unknown")
          expect(base_model.item_beneficiary_name).to eql("")
        end
      end
    end

    describe "shortened_item_beneficiary_name" do
    #let(:beneficiary_name_item) {create(:cart_item)}
      context "when kind == 'membership'" do

        it "is a string shorter than its benefitable's display_name_for_cart" do

          expect(base_model.kind).to eql(CartItem::MEMBERSHIP)
          expect(base_model.shortened_item_beneficiary_name).to be_kind_of(String)
          expect(base_model.shortened_item_beneficiary_name.length).to be < base_model.benefitable.name_for_cart.length
        end
      end

      context "when kind != 'membership'" do
        it "is an empty string" do
          base_model.update_attribute(:kind, "unknown")
          expect(base_model.kind).to eql("unknown")
          expect(base_model.shortened_item_beneficiary_name).to eql("")
        end
      end
    end

    describe "item_ready_for_payment?" do
      # Note:  item_ready_for_payment? just adds some benefitable
      # validation to item_still_available?, so here, we'll only
      # test the things that aren't duplicative.

      context "when its kind is 'unknown'" do
        context "when its benefitable is nominal" do
          it "returns true" do
            #Arrange
            base_model.update_attribute(:kind, CartItem::UNKNOWN)
            #Validate
            expect(base_model.kind).to eql(CartItem::UNKNOWN)
            expect(base_model.benefitable).to be_valid
            #Test
            expect(base_model.item_ready_for_payment?).to eql(true)
          end
        end

        context "when its benefitable is invalid" do
          it "returns true" do
            #Arrange
            base_model.update_attribute(:kind, CartItem::UNKNOWN)
            base_model.update_attribute(:first_name, "")
            #Validate
            expect(base_model.kind).to eql(CartItem::UNKNOWN)
            expect(base_model.benefitable).not_to be_valid
            #Test
            expect(base_model.item_ready_for_payment?).to be_true
          end
        end

        context "when its benefitable is missing" do
          it "returns true" do
            #Arrange
            base_model.update_attribute(:kind, CartItem::UNKNOWN)
            base_model.benefitable.update_attribute(:benefitable, nil)
            #Validate
            expect(base_model.kind).to eql(CartItem::UNKNOWN)
            expect(base_model.benefitable.blank?).to eql(true)
            #Test
            expect(base_model.item_ready_for_payment?).to eql(true)
          end
        end
      end

      context "when its kind is 'membership'" do
        context "when its benefitable is nominal" do
          it "returns true" do
            #Validate
            expect(base_model.kind).to eql(CartItem::MEMBERSHIP)
            expect(base_model.benefitable).to be_valid
            #Test
            expect(base_model.item_ready_for_payment?).to be_true
          end
        end

        context "when its benefitable is invalid" do
          it "returns false" do
            #Arrange
            base_model.update_attribute(:kind, CartItem::MEMBERSHIP)
            base_model.update_attribute(:first_name, "")
            #Validate
            expect(base_model.kind).to eql(CartItem::MEMBERSHIP)
            expect(base_model.benefitable).not_to be_valid
            #Test
            expect(base_model.item_ready_for_payment?).to be_false
          end
        end

        context "when its benefitable is missing" do
          it "returns false" do
            #Arrange
            base_model.update_attribute(:kind, CartItem::MEMBERSHIP)
            base_model.benefitable.update_attribute(:benefitable, nil)
            #Validate
            expect(base_model.kind).to eql(CartItem::MEMBERSHIP)
            expect(base_model.benefitable.blank?).to be_true
            #Test
            expect(base_model.item_ready_for_payment?).to be_false
          end
        end
      end
    end

    describe "item_reservation" do
      context "when the item has an associated Reservation" do
        let(:res_item) {create(:cart_item, :with_unpaid_reservation)}

        it "returns the item's Reservation" do
          expect(res_item.item_reservation).to be_kind_of(Reservation)
          expect(res_item.item_reservation).to eql(res_item.holdable)
        end
      end

      context "when the item does not have an associated Reservation" do

        it "returns nil" do
          #validate
          expect(base_model.holdable.blank?).to eql(true)
          #test
          expect(base_model.item_reservation).to be_nil
        end
      end

      context "when the item has a holdable that is not a Reservation" do
        let(:weird_res_item) {create(:cart_item)}
        let(:membership_holdable) {create(:membership, :adult)}

        it "returns nil" do
          weird_res_item.update_attribute(:holdable, membership_holdable)
          #validate
          expect(weird_res_item.holdable.blank?).to be_false
          expect(weird_res_item.holdable).to be_kind_of(Membership)
          #Test
          expect(weird_res_item.item_reservation).to be_nil
        end
      end
    end

    describe "item_still_available?" do
      let(:expired_membership_item) {create(:cart_item, :with_expired_membership)}

      context "when available == false" do
        it "returns false, even if it would otherwise return true." do
          # Arrangement for test validation:
          expect(base_model.available).to eql(true)
          # Test Validation:
          expect(base_model.item_still_available?).to eql(true)

          # Arrangement for actual test:
          base_model.update_attribute(:available, false)
          # Actual test:
          expect(base_model.item_still_available?).to eql(false)
        end
      end

      context "when its acquirable has expired" do

        it "returns false for acquirables that have not been changed since the CartItem was created" do
          #test validations:  Already-expired memberships
          expect(expired_membership_item.acquirable.active?).to eql(false)
          #Actual test
          expect(expired_membership_item.item_still_available?).to eql(false)
        end

        it "returns false for acquirables that have been artificially expired" do
          #test validations: acquirable artificially expired:
          expect(base_model.acquirable.active?).to eql(true)
          expect(base_model.available).to eql(true)

          #Arrangement: Artifical expiration, and confirmation of same
          base_model.acquirable.update_attribute(:active_to, 1.day.ago)
          expect(base_model.acquirable.active?).to eql(false)

          #Actual test
          expect(base_model.item_still_available?).to eql(false)
        end

        it "sets its own 'available' attribute to false when its acquirable is expired" do
          # Validation
          expect(expired_membership_item.acquirable.active?).to eql(false)
          expect(expired_membership_item.available).to eql(true)
          # Action
          expired_membership_item.item_still_available?
          # Actual test
          expect(expired_membership_item.available).to eql(false)
        end
      end

      context "when its item_name_memo doesn't match its aquirable's name" do
        let(:name_match_item) {create(:cart_item)}

        it "returns false, even if it would have returned true if the names had matched." do
          #test_validation
          expect(name_match_item.item_name_memo).to eql(name_match_item.acquirable.name)
          expect(name_match_item.item_still_available?).to eql(true)
          #Arrangement
          name_match_item.update_attribute(:item_name_memo, "altered")
          #Validation Round 2:
          expect(name_match_item.item_name_memo).not_to eql(name_match_item.acquirable.name)
          #Actual test
          expect(name_match_item.item_still_available?).to eql(false)
        end
      end

      context "when its item_price_memo doesn't match its aquirable's price_cents" do
        let(:price_match_item) {create(:cart_item)}

        it "returns false, even if it would have returned true if the names had matched." do
          # test_validation
          expect(price_match_item.item_still_available?).to eql(true)
          expect(price_match_item.item_price_memo).to eql(price_match_item.acquirable.price_cents)
          expect(price_match_item.item_still_available?).to eql(true)
          # Arrangement
          price_match_item.update_attribute(:item_price_memo, price_match_item.acquirable.price_cents + 30)
          # Secondary test validation
          expect(price_match_item.item_price_memo).not_to eql(price_match_item.acquirable.price_cents)
          # Actual test
          expect(price_match_item.item_still_available?).to eql(false)
        end

      end

      context "when its display name is unknown" do
        let(:failed_display_item) { create(:cart_item)}

        it "Even when it would otherwise return true, a display name of 'unknown' will cause it to return false" do
          #Test validations:
          expect(failed_display_item.item_display_name).not_to eql("unknown")
          expect(failed_display_item.item_still_available?).to eql(true)
          # Arrangement
          failed_display_item.update_attribute(:kind, "unknown")
          # Secondary validation
          expect(failed_display_item.item_display_name).to eql("unknown")
          expect(failed_display_item.item_still_available?).to eql(false)
        end
      end

      context "When its acquirable is invalid" do
        it "returns false" do
          #Initial Condition
          expect(base_model).to be_valid
          expect(base_model.item_still_available?).to eql(true)

          #Arrange(perturb)
          base_model.acquirable.update_attribute(:price, -10)
          #Validate
          expect(base_model).not_to be_valid
          #Test
          expect(base_model.item_still_available?).to eql(false)
        end
      end
    end
  end

  describe "item_saved_for_later?" do
    context "when the item is in a cart for later" do
      let(:later_cart) { create(:cart, :for_later_bin)}

      it "Returns true" do
        #Arrangement:
        base_model.update_attribute(:cart, later_cart)
        #test validation:
        expect(base_model.cart.status).to eql("for_later")
        #Actual test
        expect(base_model.item_saved_for_later?).to eql(true)
      end
    end

    context "when the item is in a cart for now" do
      let(:now_cart) { create(:cart, :for_now_bin)}

      it "Returns false" do
        #Arrangement:
        base_model.update_attribute(:cart, now_cart)
        #test validation:
        expect(base_model.cart.status).to eql("for_now")
        #Actual test
        expect(base_model.item_saved_for_later?).to eql(false)
      end
    end

  end

  describe "item_user" do
    let(:cart_for_now) {create(:cart, :for_now_bin)}
    it "Returns the user associated with the item's cart" do
      base_model.update_attribute(:cart, cart_for_now)
      expect(base_model.item_user).to be_kind_of(User)
      expect(base_model.item_user).to eql(base_model.cart.user)
    end
  end

  describe "validations" do
    describe "validation of 'acquirable'" do
      it "Validates the presence of the 'acquirable' attribute" do
        expect(base_model).not_to allow_value(nil).for(:acquirable)
      end
    end

    describe "validation of 'available'" do
      it "Will allow 'available' to equal false" do
        expect(base_model).to allow_value(false).for(:available)
      end

      it "Will not allow 'available' to be assigned an empty string" do
        expect(base_model).not_to allow_value("").for(:available)
      end

      it "Will not allow 'available' to be assigned nil" do
        expect(base_model).not_to allow_value(nil).for(:available)
      end

      it "Will interpret assignment of a truthy string to 'available' as an assignment of Boolean true" do
        # Arrangement and test validations:
        truthy_string = "You bet!"
        base_model.update_attribute(:available, false)
        expect(base_model.available).to eql(false)
        # Action:
        base_model.update_attribute(:available, truthy_string)
        # Tests
        expect(base_model.available).not_to eql(truthy_string)
        expect(base_model.available).to eql(true)
      end

      it "Will interpret assignment of a non-empty, falsey string to 'available' as an assignment of Boolean false" do
        #Arrangement and test validations:
        falsey_string = "F"
        base_model.update_attribute(:available, true)
        expect(base_model.available).to eql(true)
        #Action:
        base_model.update_attribute(:available, falsey_string)
        #Tests
        expect(base_model.available).not_to eql(falsey_string)
        expect(base_model.available).to eql(false)
      end
    end

    describe "validation of 'benefitable'" do
      it "Validates the presence of 'benefitable' when the value of 'kind' is 'membership'" do
        # Arrangement:
        base_model.update_attribute(:kind, "membership")
        # Test validation:
        expect(base_model.kind).to eql("membership")
        # Actual test:
        expect(base_model).not_to allow_value(nil).for(:benefitable)
      end

      it "Allows the 'benefitable' attribute to be nil when the value of 'kind' is 'unknown'" do
        # Arrangement:
        base_model.update_attribute(:kind, "unknown")
        # Test validation:
        expect(base_model.kind).to eql("unknown")
        # Actual test:
        expect(base_model).to allow_value(nil).for(:benefitable)
      end
    end

    describe "validation of 'item_name_memo'" do
      it "validates the presence of the 'item_name_memo' attribute" do
        expect(base_model).to validate_presence_of(:item_name_memo)
      end
    end

    describe "validation of 'item_price_memo'" do
      it "validates the presence of the 'item_price_memo' attribute" do
        expect(base_model).to validate_presence_of(:item_price_memo)
      end

      it "validates 'item_price_memo' as numerical" do
        expect(base_model).to validate_numericality_of(:item_price_memo)
      end
    end

    describe "validation of 'kind'" do
      it "validates the presence of the 'kind' attribute" do
        expect(base_model).to validate_presence_of(:kind)
      end

      it "will not allow 'kind' to accept the Boolean value true" do
        expect(base_model).not_to allow_value(true).for(:kind)
      end

      it "will not allow 'kind' to accept the integer value 7" do
        expect(base_model).not_to allow_value(7).for(:kind)
      end

      it "will not allow 'kind' accept the value 'meatloaf'" do
        expect(base_model).not_to allow_value('meatloaf').for(:kind)
      end

      it "WILL allow 'kind' to accept the value 'membership'" do
        expect(base_model).to allow_value('membership').for(:kind)
      end

      it "WILL allow 'kind' to accept the value 'unknown'" do
        expect(base_model).to allow_value('unknown').for(:kind)
      end
    end
  end
end
