# frozen_string_literal: true
#
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

RSpec.describe CartItemsHelper, type: :helper do

  let(:item_id_from_beyond) {CartItem.maximum(:id) + 100000}

  let(:basic_item) {create(:cart_item)}
  let(:basic_item_user) { basic_item.user}

  let(:expired_item) {create(:cart_item, :with_expired_membership)}
  let(:expired_item_user) { expired_item.user}

  let(:invalid_item) {create(:cart_item, :price_altered)}
  let(:invalid_item_user) { invalid_item.user}

  let(:paid_reservation_item) { create(:cart_item, :with_paid_reservation)}
  let(:partially_paid_reservation_item) { create(:cart_item, :with_partially_paid_reservation)}
  let(:unpaid_reservation_item) { create(:cart_item, :with_unpaid_reservation)}

  let(:empty_cart_chassis) { build(:cart_chassis)}
  let(:basic_cart_chassis) { build(:cart_chassis, :with_basic_items_cart_for_now, :with_basic_items_cart_for_later)}

  let(:fully_paid_cart_chassis) {build(:cart_chassis, :with_paid_reservations_cart_for_now, :with_paid_reservations_cart_for_later)}

  let(:unpaid_cart_chassis) {build(:cart_chassis, :with_unpaid_reservations_cart_for_now, :with_unpaid_reservations_cart_for_later)}

  describe "#self.locate_cart_item(item_id)" do
    context "when the item exists and belongs to the specified user" do
      subject(:found_item) { helper.locate_cart_item(basic_item_user, basic_item.id) }

      it "is not nil" do
        expect(subject).to be
      end

      it "is an instance of CartItem" do
        expect(subject).to be_an_instance_of(CartItem)
      end

      it "returns the expected CartItem" do
        expect(subject.id).to eql(basic_item.id)
      end
    end

    context "when the item has been destroyed" do
      before do
        @basic_item_id = basic_item.id
        @basic_item_user = basic_item.user
        basic_item.destroy
      end

      it "returns nil" do
        expect(helper.locate_cart_item(@basic_item_user, @basic_item_id)).to be_nil
      end

      it "does not raise an error" do
        expect { helper.locate_cart_item(@basic_item_user, @basic_item_id) }.not_to raise_error
      end
    end

    context "when the item has never been created" do
      subject(:found_thing) { helper.locate_cart_item(basic_item_user, item_id_from_beyond) }

      it "returns nil" do
        expect(subject).to be_nil
      end

      it "does not raise an error" do
        expect { subject }.not_to raise_error
      end
    end

    context "when the item exists, but is associated with a different user" do
      subject(:found_thing) { helper.locate_cart_item(expired_item_user, basic_item.id) }

      it "returns nil" do
        expect(subject).to be_nil
      end

      it "does not raise an error" do
        expect { subject }.not_to raise_error
      end
    end
  end

  describe "#self.reservation_payment_status(c_item)" do
    context "when the item has no reservation" do
      subject(:res_payment_status) { helper.reservation_payment_status(basic_item) }

      it "reports the lack of a reservation" do
        expect(subject[:payment_status]).to eql(CartItemsHelper::NO_RESERVATION)
        expect(subject[:status_desc]).to eql("Not reserved.")
      end
    end

    context "when the item has an unpaid reservation" do
      subject(:res_payment_status) { helper.reservation_payment_status(unpaid_reservation_item) }

      it "reports the partial reservation" do
        expect(subject[:payment_status]).to eql(CartItemsHelper::NONE)
        expect(subject[:status_desc]).to eql("Reserved but not yet paid")
      end
    end

    context "when the item has a partially paid  reservation" do
      subject(:res_payment_status) { helper.reservation_payment_status(partially_paid_reservation_item) }

      it "reports the partial reservation" do
        expect(subject[:payment_status]).to eql(CartItemsHelper::PARTIAL)
        expect(subject[:status_desc]).to eql("Reserved and paid in part.")
      end
    end

    context "when the item has a fully paid  reservation" do
      subject(:res_payment_status) { helper.reservation_payment_status(paid_reservation_item) }

      it "reports the partial reservation" do
        expect(subject[:payment_status]).to eql(CartItemsHelper::FULL)
        expect(subject[:status_desc]).to eql("Reserved and paid in full.")
      end
    end
  end









  # describe "#self.locate_cart_item_with_cart(item_id, cart_id)" do
  #
  #   context "when the item and the cart match" do
  #     let(:our_cart){create(:cart, :with_basic_items)}
  #     let(:our_cart_id) { our_cart.id }
  #     let(:our_cart_item) { our_cart.cart_items.sample }
  #     let(:our_cart_item_id) { our_cart_item.id }
  #
  #     subject(:found_thing) { helper.locate_cart_item_with_cart(our_cart_item_id, our_cart_id) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is an instance of CartItem" do
  #       expect(subject).to be_an_instance_of(CartItem)
  #     end
  #
  #     it "returns the expected CartItem" do
  #       expect(subject.id).to eql(our_cart_item_id)
  #     end
  #   end
  #
  #   context "when the item and the cart don't match" do
  #     let(:cart_a){create(:cart, :with_basic_items)}
  #     let(:cart_a_id) { cart_a.id }
  #
  #     let(:cart_b){create(:cart, :with_basic_items)}
  #     let(:cart_b_item) { cart_b.cart_items.sample }
  #     let(:cart_b_item_id) { cart_b_item.id }
  #
  #     subject(:found_thing) { helper.locate_cart_item_with_cart(cart_b_item_id, cart_a_id) }
  #
  #     it "returns nil" do
  #       expect(subject).to be_nil
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  #
  #   context "when the cart_item has been destroyed" do
  #     let(:plain_cart) {create(:cart, :with_basic_items)}
  #     let(:plain_cart_id) {plain_cart.id}
  #     let(:doomed_item) {plain_cart.cart_items.sample}
  #     let(:doomed_item_id) {doomed_item.id}
  #
  #     subject(:found_thing) { helper.locate_cart_item_with_cart(doomed_item_id, plain_cart_id) }
  #
  #     before do
  #       doomed_item.destroy
  #     end
  #
  #     it "returns nil" do
  #       expect(subject).to be_nil
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  # end

  # xdescribe "#self.cart_items_for_now(cart)" do
  #   context "when the cart has only basic items" do
  #     let(:basic_cart){create(:cart, :with_basic_items)}
  #     let(:basic_cart_now_items_count) {basic_cart.cart_items.inject(0) {|nows, i|
  #       nows += 1 if i.later == false} || 0}
  #
  #     subject(:our_nows) { helper.cart_items_for_now(basic_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is an an array of CartItems" do
  #       expect(subject).to be_an(Array)
  #       expect(subject).to all(be_an_instance_of(CartItem))
  #     end
  #
  #     it "does not include any items saved for later" do
  #       laters_seen = 0
  #       subject.each {|i| laters_seen += 1 if i.later}
  #       expect(laters_seen).to eql(0)
  #     end
  #
  #     it "includes the anticipated number of elements" do
  #       expect(subject.count).to eql(basic_cart_now_items_count)
  #     end
  #   end
  #
  #   context "when the cart has only saved items" do
  #     let(:saved_cart){ create(:cart, :with_items_for_later) }
  #     let(:saved_cart_count) { saved_cart.cart_items.count }
  #     let(:saved_cart_now_items_count) {saved_cart.cart_items.inject(0) {|nows, i|
  #       nows += 1 if i.later == false} || 0}
  #
  #     subject(:nows) { helper.cart_items_for_now(saved_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is an an empty array of CartItems" do
  #       expect(subject).to be_an(Array)
  #       expect(subject).to be_empty
  #       expect(subject).to all(be_an_instance_of(CartItem))
  #     end
  #   end
  #
  #   context "when the cart has a mix of saved and unsaved items" do
  #     let(:mixed_cart){create(:cart, :with_basic_items, :with_items_for_later)}
  #     let(:mixed_cart_count) { mixed_cart.cart_items.count }
  #     let(:mixed_cart_now_items_count) { CartItem.where(cart: mixed_cart.id, later: false).count }
  #
  #     subject(:the_nows) { helper.cart_items_for_now(mixed_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is an an array of CartItems" do
  #       expect(subject).to be_an(Array)
  #       expect(subject).to all(be_an_instance_of(CartItem))
  #     end
  #
  #     it "does not include any items saved for later" do
  #       laters_seen = 0
  #       subject.each {|i| laters_seen += 1 if i.later}
  #       expect(laters_seen).to eql(0)
  #     end
  #
  #     it "does not include all of the cart's CartItems" do
  #       expect(subject.count).to be < mixed_cart_count
  #     end
  #
  #     it "includes the anticipated number of elements" do
  #       expect(subject.count).to eql(mixed_cart_now_items_count)
  #     end
  #   end
  #
  #   context "when the cart has 100 mixed items" do
  #     let(:hundo_cart){create(:cart, :with_100_mixed_items)}
  #     let(:hundo_cart_count) { hundo_cart.cart_items.count }
  #     let(:hundo_cart_now_items_count) { CartItem.where(cart: hundo_cart.id, later: false).count }
  #
  #     subject(:hundo_nows) { helper.cart_items_for_now(hundo_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is an an array of CartItems" do
  #       expect(subject).to be_an(Array)
  #       expect(subject).to all(be_an_instance_of(CartItem))
  #     end
  #
  #     it "does not include any items saved for later" do
  #       laters_seen = 0
  #       subject.each {|i| laters_seen += 1 if i.later}
  #       expect(laters_seen).to eql(0)
  #     end
  #
  #     it "does not include all of the cart's CartItems" do
  #       expect(subject.count).to be < hundo_cart_count
  #     end
  #
  #     it "includes the anticipated number of elements" do
  #       expect(subject.count).to eql(hundo_cart_now_items_count)
  #     end
  #   end
  #
  #   context "when the cart is empty" do
  #     let(:empty_cart){ create(:cart) }
  #     let(:empty_cart_count) { empty_cart.cart_items.count }
  #
  #     subject(:nows) { helper.cart_items_for_now(empty_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is an an empty array of CartItems" do
  #       expect(subject).to be_an(Array)
  #       expect(subject).to be_empty
  #       expect(subject).to all(be_an_instance_of(CartItem))
  #     end
  #   end
  #
  #   context "when the cart is nil" do
  #     let(:nil_cart){ nil }
  #
  #     subject(:nows) { helper.cart_items_for_now(nil_cart) }
  #
  #     it "is nil" do
  #       expect(subject).to be_nil
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  # end

  # xdescribe "#self.cart_items_for_later(cart)" do
  #   context "when the cart has only basic items" do
  #     let(:base_cart){create(:cart, :with_basic_items)}
  #     let(:base_cart_later_items_count) {base_cart.cart_items.inject(0) {|laters, i|
  #       nows += 1 if i.later == true} || 0}
  #
  #     subject(:our_laters) { helper.cart_items_for_later(base_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is an an array of CartItems" do
  #       expect(subject).to be_an(Array)
  #       expect(subject).to all(be_an_instance_of(CartItem))
  #     end
  #
  #     it "does not include any items that are not saved for later" do
  #       nows_seen = 0
  #       subject.each {|i| laters_seen += 1 if !i.later}
  #       expect(nows_seen).to eql(0)
  #     end
  #
  #     it "includes the anticipated number of elements" do
  #       expect(subject.count).to eql(base_cart_later_items_count)
  #     end
  #   end
  #
  #   context "when the cart has only saved items" do
  #     let(:sav_cart){create(:cart, :with_items_for_later)}
  #     let(:sav_cart_count) { sav_cart.cart_items.count }
  #     let(:sav_cart_later_items_count) {sav_cart.cart_items.inject(0) {|laters, i|
  #       laters += 1 if i.later == true} || 0}
  #
  #     subject(:our_laters) { helper.cart_items_for_later(sav_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is an an array of CartItems" do
  #       expect(subject).to be_an(Array)
  #       expect(subject).to all(be_an_instance_of(CartItem))
  #     end
  #
  #     it "does not include any items that are not saved for later" do
  #       nows_seen = 0
  #       subject.each {|i| laters_seen += 1 if !i.later}
  #       expect(nows_seen).to eql(0)
  #     end
  #
  #     it "includes the anticipated number of elements" do
  #       expect(sav_cart_count).to eql(subject.count)
  #       expect(subject.count).to eql(sav_cart_later_items_count)
  #     end
  #   end
  #
  #   context "when the cart has a mix of saved and unsaved items" do
  #     let(:combo_cart){create(:cart, :with_basic_items, :with_items_for_later)}
  #     let(:combo_cart_count) { combo_cart.cart_items.count }
  #     let(:combo_cart_later_items_count) { CartItem.where(cart: combo_cart.id, later: true).count }
  #
  #     subject(:the_nows) { helper.cart_items_for_later(combo_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is an an array of CartItems" do
  #       expect(subject).to be_an(Array)
  #       expect(subject).to all(be_an_instance_of(CartItem))
  #     end
  #
  #     it "does not include any items that are not saved for later" do
  #       nows_seen = 0
  #       subject.each {|i| nows_seen += 1 if !i.later}
  #       expect(nows_seen).to eql(0)
  #     end
  #
  #     it "Includes some but not all of the cart's CartItems" do
  #       expect(subject.count).to be < combo_cart_count
  #       expect(subject.count).to be > 0
  #     end
  #
  #     it "includes the anticipated number of elements" do
  #       expect(subject.count).to eql(combo_cart_later_items_count)
  #     end
  #   end
  #
  #   context "when the cart has 100 mixed items" do
  #     let(:century_cart){create(:cart, :with_100_mixed_items)}
  #     let(:century_cart_count) { century_cart.cart_items.count }
  #     # let(:century_cart_later_items_count) {century_cart.cart_items.inject(0) {|laters, i|
  #     #   laters += 1 if i.later == true} || 0}
  #
  #     subject(:nows) { helper.cart_items_for_later(century_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is an an array of CartItems" do
  #       expect(subject).to be_an(Array)
  #       expect(subject).to all(be_an_instance_of(CartItem))
  #     end
  #
  #     it "does not include any items that are not saved for later" do
  #       nows_seen = 0
  #       subject.each {|i| nows_seen += 1 if !i.later}
  #       expect(nows_seen).to eql(0)
  #     end
  #
  #     it "includes some but not all of the cart's CartItems" do
  #       expect(subject.count).to be < century_cart_count
  #       expect(subject.count).to be > 0
  #     end
  #   end
  #
  #   context "when the cart is empty" do
  #     let(:blank_cart){ create(:cart) }
  #     let(:blank_cart_count) { blank_cart.cart_items.count }
  #
  #     subject(:laters) { helper.cart_items_for_later(blank_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is an an empty array of CartItems" do
  #       expect(subject).to be_an(Array)
  #       expect(subject).to be_empty
  #       expect(subject).to all(be_an_instance_of(CartItem))
  #     end
  #   end
  #
  #   context "when the cart is nil" do
  #     subject(:nows) { helper.cart_items_for_later(nil) }
  #
  #     it "is nil" do
  #       expect(subject).to be_nil
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  # end

  # describe "#self.verify_availability_of_cart_contents(cart)" do
  #
  #   context "when the cart has only basic items" do
  #     let(:b_cart){create(:cart, :with_basic_items)}
  #     let(:b_cart_count) { b_cart.cart_items.count }
  #     let(:b_cart_unavailable_items_count) {b_cart.cart_items.inject(0) {|unavails, i|
  #       unavails += 1 if i.available == false} || 0}
  #
  #     subject(:our_cart) { helper.verify_availability_of_cart_contents(b_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     it "does not result in any of the CartItems having their 'availabe' attributes' values changed to false" do
  #       unavails_seen = 0
  #       b_cart.cart_items.each {|i| unavails_seen += 1 if !i.available}
  #       expect(unavails_seen).to eql(b_cart_unavailable_items_count)
  #       expect(unavails_seen).to eql(0)
  #     end
  #   end
  #
  #   xcontext "when the cart has only saved items" do
  #     let(:saves_cart){create(:cart, :with_items_for_later)}
  #     let(:saves_cart_count) { saves_cart.cart_items.count }
  #     let(:saves_cart_unavailable_items_count) {saves_cart.cart_items.inject(0) {|unavails, i|
  #       unavails += 1 if i.available == false} || 0}
  #
  #     subject(:our_cart) { helper.verify_availability_of_cart_contents(saves_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     it "does not result in any of the CartItems having their 'availabe' attributes' values changed to false" do
  #       unavails_seen = 0
  #       saves_cart.cart_items.each {|i| unavails_seen += 1 if !i.available}
  #       expect(unavails_seen).to eql(saves_cart_unavailable_items_count)
  #       expect(unavails_seen).to eql(0)
  #     end
  #   end
  #
  #   xcontext "when the cart has only unavailable items" do
  #     let(:unavails_cart){create(:cart, :with_unavailable_items)}
  #     let(:unavails_cart_count) { unavails_cart.cart_items.count }
  #     let(:unavails_cart_unavailable_items_count) {unavails_cart.cart_items.inject(0) {|unavails, i|
  #       unavails += 1 if i.available == false} || 0}
  #
  #     subject(:our_cart) { helper.verify_availability_of_cart_contents(unavails_cart) }
  #
  #     it "is a FalseClass" do
  #       expect(subject).to be_a(FalseClass)
  #     end
  #
  #     it "returns false" do
  #       expect(subject).to eql(false)
  #     end
  #
  #     it "results in all items in the cart having their 'available' attributes' values remain false" do
  #       unavails_seen = 0
  #       unavails_cart.cart_items.each {|i| unavails_seen += 1 if !i.available}
  #       expect(unavails_seen).to eql(unavails_cart_unavailable_items_count)
  #       expect(unavails_seen).to eql(unavails_cart_count)
  #     end
  #   end
  #
  #   context "when the cart has a mix of problematic items" do
  #     let(:probs_cart){create(:cart, :with_all_problematic_items)}
  #     let(:probs_cart_count) { probs_cart.cart_items.count }
  #     let(:probs_cart_unavailable_items_count) {probs_cart.cart_items.inject(0) {|unavails, i|
  #       unavails += 1 if i.available == false} || 0}
  #
  #     subject(:our_cart) { helper.verify_availability_of_cart_contents(probs_cart) }
  #
  #     it "is a FalseClass" do
  #       expect(subject).to be_a(FalseClass)
  #     end
  #
  #     it "returns false" do
  #       expect(subject).to eql(false)
  #     end
  #   end
  #
  #   context "when the cart has a mix of problematic and non-problematic items" do
  #     let(:prob_mix_cart){create(:cart, :with_all_problematic_items, :with_basic_items)}
  #     let(:prob_mix_cart_count) { prob_mix_cart.cart_items.count }
  #     let(:prob_mix_cart_unavailable_items_count) {prob_mix_cart.cart_items.inject(0) {|unavails, i|
  #       unavails += 1 if i.available == false} || 0}
  #
  #     subject(:our_cart) { helper.verify_availability_of_cart_contents(prob_mix_cart) }
  #
  #     it "is a FalseClass" do
  #       expect(subject).to be_a(FalseClass)
  #     end
  #
  #     it "returns false" do
  #       expect(subject).to eql(false)
  #     end
  #   end
  #
  #   xcontext "when the cart has 100 mixed items" do
  #     let(:hundred_cart){create(:cart, :with_100_mixed_items)}
  #     let(:hundred_cart_count) { hundred_cart.cart_items.count }
  #
  #     subject(:our_avails) { helper.verify_availability_of_cart_contents(hundred_cart) }
  #
  #     it "is a FalseClass" do
  #       expect(subject).to be_a(FalseClass)
  #     end
  #
  #     it "returns false" do
  #       expect(subject).to eql(false)
  #     end
  #   end
  #
  #   xcontext "when the cart is empty" do
  #     let(:hollow_cart) { create(:cart) }
  #     subject(:found_thing) { helper.verify_availability_of_cart_contents(hollow_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  #
  #   xcontext "when the cart is nil" do
  #     let(:nil_cart) { nil }
  #     subject(:found_thing) { helper.verify_availability_of_cart_contents(nil_cart) }
  #
  #     it "returns nil" do
  #       expect(subject).to be_nil
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  # end

  # xdescribe "#self.destroy_cart_contents(cart)" do
  #   context "when the cart has only basic items" do
  #     let(:ba_cart){create(:cart, :with_basic_items)}
  #     let(:ba_cart_id) {ba_cart.id}
  #     let(:ba_cart_count) { ba_cart.cart_items.count }
  #
  #     subject(:our_cart) { helper.destroy_cart_contents(ba_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_test_basic_cart) {create(:cart, :with_basic_items)}
  #
  #       it "causes all the cart's items to be removed" do
  #         before_count = destroy_test_basic_cart.cart_items.count
  #         helper.destroy_cart_contents(subject)
  #         expect(before_count).to be > 0
  #         expect(subject.cart_items.count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has only saved items" do
  #     let(:sa_cart){create(:cart, :with_items_for_later)}
  #     let(:sa_cart_id) {sa_cart.id}
  #     let(:sa_cart_count) { sa_cart.cart_items.count }
  #
  #     subject(:sa) { helper.destroy_cart_contents(sa_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_test_saved_cart) {create(:cart, :with_items_for_later)}
  #
  #       it "causes all the cart's items to be removed" do
  #         before_count = destroy_test_saved_cart.cart_items.count
  #         helper.destroy_cart_contents(subject)
  #         expect(before_count).to be > 0
  #         expect(subject.cart_items.count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has only unavailable items" do
  #     let(:unavs_cart){create(:cart, :with_unavailable_items)}
  #     let(:unavs_cart_id) { unavs_cart.id }
  #     let(:unavs_cart_count) { unavs_cart.cart_items.count }
  #
  #     subject(:our_cart) { helper.destroy_cart_contents(unavs_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_test_unav_cart) {create(:cart, :with_unavailable_items)}
  #
  #       it "causes all the cart's items to be removed" do
  #         before_count = destroy_test_unav_cart.cart_items.count
  #         helper.destroy_cart_contents(subject)
  #         expect(before_count).to be > 0
  #         expect(subject.cart_items.count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has a mix of problematic items" do
  #     let(:ps_cart){create(:cart, :with_all_problematic_items)}
  #
  #     subject(:ps) { helper.destroy_cart_contents(ps_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_test_allp_cart) {create(:cart, :with_all_problematic_items)}
  #
  #       it "causes all the cart's items to be removed" do
  #         before_count = destroy_test_allp_cart.cart_items.count
  #         helper.destroy_cart_contents(subject)
  #         expect(before_count).to be > 0
  #         expect(destroy_test_allp_cart.cart_items.count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has a mix of problematic and non-problematic items" do
  #     let(:prob_mix_cart){create(:cart, :with_all_problematic_items, :with_basic_items)}
  #
  #     subject(:prob_mix) { helper.destroy_cart_contents(prob_mix_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_test_prmix_cart) {create(:cart, :with_basic_items)}
  #
  #       it "causes all the cart's items to be removed" do
  #         before_count = destroy_test_prmix_cart.cart_items.count
  #         helper.destroy_cart_contents(subject)
  #         expect(before_count).to be > 0
  #         expect(subject.cart_items.count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has 100 mixed items" do
  #     let(:hundy_cart){ create(:cart, :with_100_mixed_items) }
  #
  #     subject(:hundy) { helper.destroy_cart_contents(hundy_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_test_hundy_cart) {create(:cart, :with_100_mixed_items)}
  #
  #       it "causes all the cart's items to be removed" do
  #         before_count = destroy_test_hundy_cart.cart_items.count
  #         helper.destroy_cart_contents(subject)
  #         expect(before_count).to be > 0
  #         expect(subject.cart_items.count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart is empty" do
  #     let(:abandoned_cart) { create(:cart) }
  #
  #     subject(:abandoned) { helper.destroy_cart_contents(abandoned_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  #
  #   context "when the cart is nil" do
  #     subject(:nil_cart) { helper.destroy_cart_contents(nil) }
  #
  #     it "is nil" do
  #       expect(subject).to be_nil
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  # end

  # xdescribe "#self.destroy_for_now_cart_items(cart)" do
  #   context "when the cart has only basic items" do
  #     let(:bb_cart){create(:cart, :with_basic_items)}
  #
  #     subject(:bb) { helper.destroy_for_now_cart_items(bb_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_now_basic_cart) {create(:cart, :with_basic_items)}
  #
  #       it "causes all the cart's items to be removed" do
  #         nows_count_before = 0
  #         subject.cart_items.each {|i| nows_count_before += 1 if !i.later }
  #         helper.destroy_for_now_cart_items(subject)
  #         nows_count_after = 0
  #         subject.cart_items.each {|i| nows_count_after += 1 if !i.later }
  #
  #         expect(nows_count_before).to be > 0
  #         expect(nows_count_after).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has only saved items" do
  #     let(:sl_cart){create(:cart, :with_items_for_later)}
  #
  #     subject(:our_cart) { helper.destroy_for_now_cart_items(sl_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_now_saved_cart) {create(:cart, :with_items_for_later)}
  #
  #       it "does not result in any of the CartItems being removed" do
  #         before_count = subject.cart_items.count
  #         helper.destroy_for_now_cart_items(subject)
  #         expect(before_count).to be > 0
  #         expect(subject.cart_items.count).to eql(before_count)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has only unavailable items" do
  #     let(:ua_cart){create(:cart, :with_unavailable_items)}
  #
  #     subject(:our_cart) { helper.destroy_for_now_cart_items(ua_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_now_ua_cart) {create(:cart, :with_unavailable_items)}
  #
  #       it "results in all the CartItems being removed" do
  #         before_count = subject.cart_items.count
  #         helper.destroy_for_now_cart_items(subject)
  #         expect(before_count).to be > 0
  #         expect(subject.cart_items.count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has a mix of problematic items" do
  #     let(:prb_cart){create(:cart, :with_all_problematic_items)}
  #     subject(:our_cart) { helper.destroy_for_now_cart_items(prb_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_now_prb_cart) {create(:cart, :with_unavailable_items)}
  #
  #       it "results in all CartItems being removed" do
  #         before_count = subject.cart_items.count
  #         helper.destroy_for_now_cart_items(subject)
  #         expect(before_count).to be > 0
  #         expect(subject.cart_items.count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has a mix of problematic and non-problematic items" do
  #     let(:prb_mix_cart){create(:cart, :with_all_problematic_items, :with_basic_items)}
  #
  #     subject(:our_cart) { helper.destroy_for_now_cart_items(prb_mix_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_now_prbmix_cart) {create(:cart, :with_unavailable_items)}
  #
  #       it "results in all CartItems being removed" do
  #         before_count = subject.cart_items.count
  #         helper.destroy_for_now_cart_items(subject)
  #         expect(before_count).to be > 0
  #         expect(subject.cart_items.count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has 100 mixed items" do
  #     let(:hundyyy_cart){ create(:cart, :with_100_mixed_items) }
  #
  #     subject(:our_cart) { helper.destroy_for_now_cart_items(hundyyy_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_now_hundy_cart) {create(:cart, :with_unavailable_items)}
  #
  #       it "results in all CartItems that are not saved for later being removed" do
  #         before_nows_count = 0
  #         subject.cart_items.each {|i| before_nows_count += 1 if !i.later}
  #
  #         helper.destroy_for_now_cart_items(subject)
  #
  #         after_nows_count = 0
  #         subject.cart_items.each {|i| before_nows_count += 1 if !i.later}
  #
  #         expect(before_nows_count).to be > 0
  #         expect(after_nows_count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart is empty" do
  #     let(:abandoned_cart) { create(:cart) }
  #
  #     subject(:our_cart) { helper.destroy_for_now_cart_items(abandoned_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  #
  #   context "when the cart is nil" do
  #     subject(:our_cart) { helper.destroy_for_now_cart_items(nil) }
  #
  #     it "is nil" do
  #       expect(subject).to be_nil
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  # end
  #
  # xdescribe "#self.destroy_cart_items_for_later(cart)" do
  #   context "when the cart has only basic items" do
  #     let(:bas_c){create(:cart, :with_basic_items)}
  #
  #     subject(:our_subj) { helper.destroy_cart_items_for_later(bas_c) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_later_basic_cart) {create(:cart, :with_basic_items)}
  #
  #       it "does not result in any CartItems being removed" do
  #         before_count = subject.cart_items.count
  #         helper.destroy_cart_items_for_later(subject)
  #         expect(before_count).to be > 0
  #         expect(subject.cart_items.count).to eql(before_count)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has only saved items" do
  #     let(:sala_cart){create(:cart, :with_items_for_later)}
  #
  #     subject(:our_subj) { helper.destroy_cart_items_for_later(sala_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_later_saved_cart) {create(:cart, :with_items_for_later)}
  #
  #       it "results in all of the CartItems being removed" do
  #         before_count = subject.cart_items.count
  #         helper.destroy_cart_items_for_later(subject)
  #         expect(before_count).to be > 0
  #         expect(subject.cart_items.count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has a mix of problematic items" do
  #     let(:prbs_cart){create(:cart, :with_all_problematic_items)}
  #     subject(:our_subj) { helper.destroy_cart_items_for_later(prbs_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_now_prb_cart) {create(:cart, :with_all_problematic_items)}
  #
  #       it "results in all CartItems being removed" do
  #         before_count = subject.cart_items.count
  #         helper.destroy_for_now_cart_items(subject)
  #         expect(before_count).to be > 0
  #         expect(subject.cart_items.count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has a mix of problematic and non-problematic items" do
  #     let(:prbs_plus_cart){create(:cart, :with_all_problematic_items, :with_basic_items)}
  #
  #     subject(:our_subj) { helper.destroy_cart_items_for_later(prbs_plus_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_later_prbmix_cart) {create(:cart, :with_all_problematic_items, :with_basic_items)}
  #
  #       it "does not result any CartItems being removed" do
  #         before_count = subject.cart_items.count
  #         helper.destroy_cart_items_for_later(subject)
  #         expect(before_count).to be > 0
  #         expect(subject.cart_items.count).to eql(before_count)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has 100 mixed items" do
  #     let(:hundie_cart){ create(:cart, :with_100_mixed_items) }
  #
  #     subject(:our_subj) { helper.destroy_cart_items_for_later(hundie_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:destroy_now_hundy_cart) {create(:cart, :with_100_mixed_items)}
  #
  #       it "results in all CartItems that are saved for later being removed" do
  #         before_laters_count = 0
  #         subject.cart_items.each {|i| before_laters_count += 1 if i.later}
  #
  #         helper.destroy_cart_items_for_later(subject)
  #
  #         after_laters_count = 0
  #         subject.cart_items.each {|i| before_laters_count += 1 if i.later}
  #
  #         expect(before_laters_count).to be > 0
  #         expect(after_laters_count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart is empty" do
  #     let(:abandoned_cart) { create(:cart) }
  #
  #     subject(:our_cart) { helper.destroy_cart_items_for_later(abandoned_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  #
  #   context "when the cart is nil" do
  #     subject(:our_cart) { helper.destroy_cart_items_for_later(nil) }
  #
  #     it "is nil" do
  #       expect(subject).to be_nil
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  # end
  #
  # xdescribe "#self.save_all_cart_items_for_later(cart)" do
  #   context "when the cart has only basic items" do
  #     let(:our_bas_c){create(:cart, :with_basic_items)}
  #
  #     subject(:bas) { helper.save_all_cart_items_for_later(our_bas_c) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:for_later_basic_cart) {create(:cart, :with_basic_items)}
  #
  #       it "results in the cart containing nothing but items saved for later" do
  #         before_laters_count = 0
  #         subject.cart_items.each {|i| before_laters_count += 1 if i.later}
  #
  #         helper.save_all_cart_items_for_later(subject)
  #
  #         after_laters_count = 0
  #         subject.cart_items.each {|i| after_laters_count += 1 if i.later}
  #
  #         expect(before_laters_count).to eql(0)
  #         expect(after_laters_count).to eql(subject.cart_items.count)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has only saved items" do
  #     let(:sla_cart){create(:cart, :with_items_for_later)}
  #
  #     subject(:our_subj) { helper.save_all_cart_items_for_later(sla_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:for_later_saved_cart) {create(:cart, :with_items_for_later)}
  #
  #       it "results in the cart continuing to contain nothing but items saved for later" do
  #         before_laters_count = 0
  #         subject.cart_items.each {|i| before_laters_count += 1 if i.later}
  #
  #         helper.save_all_cart_items_for_later(subject)
  #
  #         after_laters_count = 0
  #         subject.cart_items.each {|i| after_laters_count += 1 if i.later}
  #
  #         expect(before_laters_count).to eql(subject.cart_items.count)
  #         expect(after_laters_count).to eql(before_laters_count)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has a mix of problematic items" do
  #     let(:prbses_cart){create(:cart, :with_all_problematic_items)}
  #     subject(:our_subj) { helper.save_all_cart_items_for_later(prbses_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:for_later_prbses_cart) {create(:cart, :with_all_problematic_items)}
  #
  #       it "results in the cart containing nothing but items saved for later" do
  #         before_laters_count = 0
  #         subject.cart_items.each {|i| before_laters_count += 1 if i.later}
  #
  #         helper.save_all_cart_items_for_later(subject)
  #
  #         after_laters_count = 0
  #         subject.cart_items.each {|i| after_laters_count += 1 if i.later}
  #
  #         expect(before_laters_count).to eql(0)
  #         expect(after_laters_count).to eql(subject.cart_items.count)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has a mix of problematic and non-problematic items" do
  #     let(:prbses_plus_cart){create(:cart, :with_all_problematic_items, :with_basic_items)}
  #
  #     subject(:our_subj) { helper.save_all_cart_items_for_later(prbses_plus_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:for_later_prbses_plus_cart) {create(:cart, :with_all_problematic_items, :with_basic_items)}
  #
  #       it "results in all items in the cart being saved for later" do
  #         before_laters_count = 0
  #         subject.cart_items.each {|i| before_laters_count += 1 if i.later}
  #
  #         helper.save_all_cart_items_for_later(subject)
  #
  #         after_laters_count = 0
  #         subject.cart_items.each {|i| after_laters_count += 1 if i.later}
  #
  #         expect(before_laters_count).to eql(0)
  #         expect(after_laters_count).to eql(subject.cart_items.count)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has 100 mixed items" do
  #     let(:hundee_cart){ create(:cart, :with_100_mixed_items) }
  #
  #     subject(:our_subj) { helper.save_all_cart_items_for_later(hundee_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:hundee_later_cart) {create(:cart, :with_100_mixed_items)}
  #
  #       it "results in all items in the cart being saved for later" do
  #         before_laters_count = 0
  #         subject.cart_items.each {|i| before_laters_count += 1 if i.later}
  #
  #         helper.save_all_cart_items_for_later(subject)
  #
  #         after_laters_count = 0
  #         subject.cart_items.each {|i| after_laters_count += 1 if i.later}
  #
  #         expect(before_laters_count).to be > 0
  #         expect(before_laters_count).to be < subject.cart_items.count
  #         expect(after_laters_count).to eql(subject.cart_items.count)
  #       end
  #     end
  #   end
  #
  #   context "when the cart is empty" do
  #     let(:desolation_cart) { create(:cart) }
  #
  #     subject(:our_subj) { helper.destroy_cart_items_for_later(desolation_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  #
  #   context "when the cart is nil" do
  #     subject(:our_subj) { helper.destroy_cart_items_for_later(nil) }
  #
  #     it "is nil" do
  #       expect(subject).to be_nil
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  # end
  #
  # xdescribe "#self.unsave_all_cart_items(cart)" do
  #   context "when the  art has only incomplete items" do
  #     pending
  #   end
  #
  #   context "when the cart has only basic items" do
  #     let(:our_bas_cart){create(:cart, :with_basic_items)}
  #
  #     subject(:bas) { helper.unsave_all_cart_items(our_bas_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:unsave_basic_cart) {create(:cart, :with_basic_items)}
  #
  #       it "results in the cart continuing to contain no items that are saved for later" do
  #         before_laters_count = 0
  #         subject.cart_items.each {|i| before_laters_count += 1 if i.later}
  #
  #         helper.unsave_all_cart_items(subject)
  #
  #         after_laters_count = 0
  #         subject.cart_items.each {|i| after_laters_count += 1 if i.later}
  #
  #         expect(subject.cart_items.count).to be > 0
  #         expect(before_laters_count).to eql(0)
  #         expect(after_laters_count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has only saved items" do
  #     let(:svlts_cart){create(:cart, :with_items_for_later)}
  #
  #     subject(:our_subj) { helper.unsave_all_cart_items(svlts_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:unsave_later_cart) {create(:cart, :with_items_for_later)}
  #
  #       it "changes all items in the cart from saved-for-later to not saved-for-later" do
  #         before_laters_count = 0
  #         subject.cart_items.each {|i| before_laters_count += 1 if i.later}
  #
  #         helper.unsave_all_cart_items(subject)
  #
  #         after_laters_count = 0
  #         subject.cart_items.each {|i| after_laters_count += 1 if i.later}
  #
  #         expect(before_laters_count).to eql(subject.cart_items.count)
  #         expect(after_laters_count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has a mix of problematic items" do
  #     let(:probses_cart){create(:cart, :with_all_problematic_items)}
  #     subject(:our_subj) { helper.unsave_all_cart_items(probses_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:unsave_probses_cart) {create(:cart, :with_all_problematic_items)}
  #
  #       it "results in the cart continuing to contain no items that are saved-for-later" do
  #         before_laters_count = 0
  #         subject.cart_items.each {|i| before_laters_count += 1 if i.later}
  #
  #         helper.unsave_all_cart_items(subject)
  #
  #         after_laters_count = 0
  #         subject.cart_items.each {|i| after_laters_count += 1 if i.later}
  #
  #         expect(subject.cart_items.count).to be > 0
  #         expect(before_laters_count).to eql(0)
  #         expect(after_laters_count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has a mix of problematic and non-problematic items" do
  #     let(:probses_plus_cart){create(:cart, :with_all_problematic_items, :with_basic_items)}
  #
  #     subject(:our_subj) { helper.unsave_all_cart_items(probses_plus_cart) }
  #
  #     it "is not nil" do
  #       expect(subject).to be
  #     end
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:unsave_probses_plus_cart) {create(:cart, :with_all_problematic_items, :with_basic_items)}
  #
  #       it "results in the cart continuing to contain no items that are saved-for-later" do
  #         before_laters_count = 0
  #         subject.cart_items.each {|i| before_laters_count += 1 if i.later}
  #
  #         helper.unsave_all_cart_items(subject)
  #
  #         after_laters_count = 0
  #         subject.cart_items.each {|i| after_laters_count += 1 if i.later}
  #
  #         expect(subject.cart_items.count).to be > 0
  #         expect(before_laters_count).to eql(0)
  #         expect(after_laters_count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart has 100 mixed items" do
  #     let(:our_hundee_cart){ create(:cart, :with_100_mixed_items) }
  #
  #     subject(:our_subj) { helper.unsave_all_cart_items(our_hundee_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     context "examining the cart" do
  #       subject (:hundee_unsave_cart) {create(:cart, :with_100_mixed_items)}
  #
  #       it "results in the cart containing no items that are saved-for-later" do
  #         before_laters_count = 0
  #         subject.cart_items.each {|i| before_laters_count += 1 if i.later}
  #
  #         helper.unsave_all_cart_items(subject)
  #
  #         after_laters_count = 0
  #         subject.cart_items.each {|i| after_laters_count += 1 if i.later}
  #
  #         expect(before_laters_count).to be > 0
  #         expect(before_laters_count).to be < subject.cart_items.count
  #         expect(after_laters_count).to eql(0)
  #       end
  #     end
  #   end
  #
  #   context "when the cart is empty" do
  #     let(:nada_cart) { create(:cart) }
  #
  #     subject(:our_subj) { helper.destroy_cart_items_for_later(nada_cart) }
  #
  #     it "is a TrueClass" do
  #       expect(subject).to be_a(TrueClass)
  #     end
  #
  #     it "returns true" do
  #       expect(subject).to eql(true)
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  #
  #   context "when the cart is nil" do
  #     subject(:our_subj) { helper.destroy_cart_items_for_later(nil) }
  #
  #     it "is nil" do
  #       expect(subject).to be_nil
  #     end
  #
  #     it "does not raise an error" do
  #       expect { subject }.not_to raise_error
  #     end
  #   end
  # end

  describe "#self.ready_for_payment?(c_chassis)" do
    # NOTE:  This is just a wrapper for a CartChassis instance method, for
    # purposes of making it more usable in the view.  It's more thorougly tested in
    # the CartChassis spec.

    context "when the for_now bin is empty" do
      subject(:ready) { helper.ready_for_payment?(empty_cart_chassis) }

      it "reports negative" do
        expect(subject[:verified]).to eql(false)
      end

      it "does not report problem items" do
        expect(subject[:problem_items].length).to eql(0)
      end
    end

    context "when the for_now bin holds only basic membership items" do
      subject(:ready) { helper.ready_for_payment?(basic_cart_chassis) }

      it "reports positive" do
        expect(subject[:verified]).to eql(true)
      end

      it "does not report problem items" do
        expect(subject[:problem_items].length).to eql(0)
      end
    end

    context "when the for_now bin holds basic items, plus one expired item" do
      subject(:ready) { helper.ready_for_payment?(basic_cart_chassis) }

      before do
        expired_item.update_attribute(:cart, basic_cart_chassis.now_bin)
      end

      it "reports negative" do
        expect(subject[:verified]).to eql(false)
      end

      it "reports one problem items" do
        expect(subject[:problem_items].length).to eql(1)
      end
    end
  end

  describe "#self.items_with_reservations_present?(c_chassis)" do
    # Note: This is a wrapper for a query object, to make it more smoothly
    # available to the view.  This will be tested much more thoroughly the in
    # the spec for the query object (ReservationsInCart).

    context "when the cart is empty" do
      subject(:res_present) { helper.items_with_reservations_present?(empty_cart_chassis.now_bin) }

      it "reports negative" do
        expect(subject).to eql(false)
      end
    end

    context "when there is one item with an unpaid reservation in the specified bin" do
      subject(:res_present) { helper.items_with_reservations_present?(basic_cart_chassis.now_bin) }

      before do
        unpaid_reservation_item.update_attribute(:cart, basic_cart_chassis.now_bin)
      end

      it "reports positive" do
        expect(subject).to eql(true)
      end
    end

    context "when there is one item with a paid reservation in the specified bin" do
      subject(:res_present) { helper.items_with_reservations_present?(basic_cart_chassis.later_bin) }

      before do
        paid_reservation_item.update_attribute(:cart, basic_cart_chassis.later_bin)
      end

      it "reports positive" do
        expect(subject).to eql(true)
      end
    end
  end

  describe "#reserve_and_pay_button_text" do
    context "when the cart is empty" do
      subject(:res_present) { helper.reserve_and_pay_button_text(empty_cart_chassis) }

      it "doesn't include the reservation language" do
        expect(subject).to eql("Pay Online Now")
      end
    end

    context "when the cart contains only basic membership items without reservations" do
      subject(:res_present) { helper.reserve_and_pay_button_text(basic_cart_chassis) }

      it "Includes the reservation language" do
        expect(subject).to eql("Reserve and Pay Online Now")
      end
    end

    context "when the cart contains only unpaid reservation items" do
      subject(:res_present) { helper.reserve_and_pay_button_text(unpaid_cart_chassis) }

      it "Doesn't include the reservation language" do
        expect(subject).to eql("Pay Online Now")
      end
    end

    context "when the cart contains only fully paid reservation items" do
      subject(:res_present) { helper.reserve_and_pay_button_text(fully_paid_cart_chassis) }

      it "Doesn't include the reservation language" do
        expect(subject).to eql("Pay Online Now")
      end
    end
  end

  xdescribe "#group_deletion_button" do
    pending
  end

  xdescribe "#add_admin_buttons" do
    pending
  end
end
