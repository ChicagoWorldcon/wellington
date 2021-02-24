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

RSpec.describe CartController, type: :controller do

  let(:contact_model_key) { Claim.contact_strategy.to_s.underscore.to_sym }

  let(:tuatara) { create(:membership, :tuatara)}
  let(:offer_expired) {MembershipOffer.new(tuatara)}

  let(:valid_contact_params) do
    FactoryBot.build(:chicago_contact).slice(
      :first_name,
      :last_name,
      :publication_format,
      :address_line_1,
      :country,
      :email,
    )
  end

  let(:valid_contact_params_with_dob) do
    FactoryBot.build(:chicago_contact).slice(
      :first_name,
      :last_name,
      :publication_format,
      :address_line_1,
      :country,
      :email,
      :date_of_birth
    )
  end

  let(:invalid_contact_params) do
    FactoryBot.build(:chicago_contact).slice(
      :first_name,
      :last_name,
      :publication_format,
      :country,
      :email
    )
  end

  let(:support_user) { create(:support)}

  describe "#show" do
    context "when a first-time user is signed in" do
      render_views
      let(:naive_user) { create(:user)}
      before do
        sign_in(naive_user)
        get :show
      end
      after do
        sign_out(naive_user)
      end
      xit "creates a cart for the new user" do
        expect(assigns(:cart)).not_to be_a(Cart) #inverted

        # Why yes, as a matter of fact, this IS the worst sin
        # against controller-testing best practices ever!
        # Eventually, this will probably get removed to a
        # feature or request test.
        expect(assigns(:cart).user).not_to eql(naive_user) #inverted
        expect(assigns(:cart).cart_items.count).not_to eql(0) #inverted
      end
      xit "renders" do
        expect(response).not_to have_http_status(:ok) #inverted
        expect(subject).not_to render_template(:cart) #inverted
      end
    end

    context "when a user with an existing cart is signed in" do
      let(:existing_cart) {create(:cart, :with_basic_items)}
      let(:existing_user) {existing_cart.user}

      before do
        sign_in(existing_user)
        get :show
      end

      after do
        sign_out(existing_user)
      end

      xit "finds the user's cart" do
        expect(assigns(:cart)).not_to eq(existing_cart) #inverted
      end

      xit "renders" do
        expect(response).not_to have_http_status(:ok) #inverted
      end
    end

    context "when a support user is signed in" do
      render_views

      before do
        sign_in(support_user)
        get :show
      end

      after do
        sign_out(support_user)
      end

      xit "redirects to the root path" do
        expect(response).not_to have_http_status(:found) #inverted
        expect(response).not_to redirect_to(root_path) #inverted
      end

      xit "sets a flash message about logging into your personal account to make personal purchases"  do
        expect(subject).not_to set_flash[:alert].to(/personal/) #inverted
      end
    end

    context "without sign-in" do
      before do
        get :show
      end

      xit "redirects to the root path" do
        expect(response).not_to have_http_status(:found) #inverted
        expect(response).not_to redirect_to(root_path) #inverted
      end
    end
  end

  describe "#add_reservation_to_cart" do
    context "when the membembership is active and the beneficiary has all the necessary info" do
      render_views
      let(:adult) { create(:membership, :adult) }
      let(:offer_valid) { MembershipOffer.new(adult) }

      let!(:good_enough_cart) {create(:cart, :with_basic_items)}
      let!(:good_enough_user) { good_enough_cart.user }

      let!(:starting_good_enough_cart_count) {good_enough_cart.cart_items.count}

      before do
        sign_in(good_enough_user)

        post :add_reservation_to_cart, params: {
          contact_model_key => valid_contact_params_with_dob,
          :offer => offer_valid.hash
        }
      end

      after do
        sign_out(good_enough_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the cart template" do
        expect(subject).to render_template(:cart)
      end

      it "locates the user's cart" do
        expect(assigns(:cart)).to be_a(Cart)
        expect(assigns(:cart)).to eq(good_enough_cart)
        expect(assigns(:cart).user).to eq(good_enough_user)
      end

      it "creates an offer object per our params" do
        expect(assigns(:our_offer)).to be_a(MembershipOffer)
        expect(assigns(:our_offer).hash).to eq(offer_valid.hash)
      end

      it "creates a contact object" do
        expect(assigns(:our_beneficiary)).to be_a(Claim.contact_strategy)
        expect(assigns(:our_beneficiary).first_name).to eq(valid_contact_params_with_dob[:first_name])
      end

      it "populates the contact object's date_of_birth field with a date object" do
        expect(assigns(:our_beneficiary).date_of_birth).to be_a(Date)
      end

      it "creates a cart item per our params" do
        expect(assigns(:our_cart_item)).to be_a(CartItem)
        expect(assigns(:our_cart_item).acquirable.name).to eq(offer_valid.membership.name)
        expect(assigns(:our_cart_item).benefitable.last_name).to eq(valid_contact_params_with_dob[:last_name])
      end

      it "adds the new CartItem to the cart" do
        expect(assigns(:cart).cart_items.count).to eql(starting_good_enough_cart_count + 1)
        found_in_cart = assigns(:cart).cart_items.find {|i| i.id == assigns(:our_cart_item).id }
        expect(assigns(:our_cart_item)).to eq(found_in_cart)
      end
    end

    context "when there are issues with the beneficiary or the membership" do
      let(:good_enough_cart) {create(:cart, :with_basic_items)}
      let(:good_enough_user) { good_enough_cart.user }

      context "when the HTTP_REFERER has been set" do

        before do
          sign_in(good_enough_user)
        end

        after do
          sign_out(good_enough_user)
        end

        before(:each) do
          request.env['HTTP_REFERER'] = memberships_path
        end

        context "when the membership offer is expired" do
          let(:starting_good_enough_cart_count) {good_enough_cart.cart_items.count}

          before do
            post :add_reservation_to_cart, params: {
              contact_model_key => valid_contact_params_with_dob,
              :offer => offer_expired.hash
            }
          end

          it "redirects to the path from 'HTTP_REFERER'" do
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(memberships_path)
          end

          it "sets a flash error about the membership no longer being available" do
            expect(subject).to set_flash[:error].to(/no longer available/i)
          end

          it "does not add a new item to the cart" do
            expect(assigns(:cart).cart_items.count).to eql(starting_good_enough_cart_count)
          end
        end
      end

      context "when the HTTP_REFERER has not been set" do
        before do
          sign_in(good_enough_user)
        end

        after do
          sign_out(good_enough_user)
        end

        before(:each) do
          request.env['HTTP_REFERER'] = nil
        end

        context "when the beneficiary is invalid" do
          let(:adult) { create(:membership, :adult) }
          let(:offer_valid) { MembershipOffer.new(adult) }
          let(:starting_good_enough_cart_count) {good_enough_cart.cart_items.count}

          before do
            post :add_reservation_to_cart, params: {
              contact_model_key => invalid_contact_params,
              :offer => offer_valid.hash
            }
          end

          it "redirects to the fallback path" do
            expect(response).to have_http_status(:found)
            expect(response).to redirect_to(root_path)
          end

          it "sets a flash error" do
            expect(subject).to set_flash[:error].to(/address/i)
          end

          it "does not add the item to the cart" do
            expect(assigns(:cart).cart_items.count).to eql(starting_good_enough_cart_count)
          end
        end
      end

      context "when the beneficiary params do not include a date of birth" do
        let(:adult) { create(:membership, :adult) }
        let(:offer_valid) { MembershipOffer.new(adult) }

        let(:starting_good_enough_cart_count) {good_enough_cart.cart_items.count}

        before do
          sign_in(good_enough_user)

          post :add_reservation_to_cart, params: {
            contact_model_key => valid_contact_params,
            :offer => offer_valid.hash
          }
        end

        after do
          sign_out(good_enough_user)
        end

        it "leaves the contact object's date_of_birth field empty" do
          expect(assigns(:our_beneficiary).date_of_birth).to be_nil
        end

        xcontext "when the membership requires a date of birth" do
          it "marks the item incomplete" do
            pending
            expect(assigns(:our_cart_item.incomplete).to eql(true))
          end

          it "adds the item to the cart" do
            pending
            expect(assigns(:cart).cart_items.count).to eql(starting_good_enough_cart_count + 1)
            expect(assigns(:our_cart_item).cart).to eq(assigns(:cart))
          end
        end
      end
    end
  end

  describe "#destroy" do

    context "when the cart is empty" do
      render_views

      let!(:empty_cart) { create(:cart)}
      let!(:empty_user) { empty_cart.user }
      let!(:empty_cart_count) { empty_cart.cart_items.count }
      let!(:empty_cart_id) { empty_cart.id }

      before do
        sign_in(empty_user)
        delete :destroy
      end

      after do
        sign_out(empty_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "does not destroy the Cart object" do
        expect(assigns(:cart)).to be
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart).id).to eql(empty_cart_id)
        expect(assigns(:cart)).to eq(empty_cart)
      end


      it "ends with the cart completely empty" do
        #Validation of the test:
        expect(assigns(:cart).cart_items.count).to eql(empty_cart_count)

        #actual test:
        expect(assigns(:cart).cart_items.count).to eql(0)
      end
    end

    context "when the cart has every kind of item" do
      render_views

      let!(:full_cart) {create(:cart, :with_basic_items, :with_free_items, :with_items_for_later, :with_unavailable_items, :with_incomplete_items, :with_expired_membership_items)}
      let!(:full_cart_count) { full_cart.cart_items.count }
      let!(:full_cart_user) { full_cart.user }
      let!(:full_cart_id) { full_cart.id }

      before do
        sign_in(full_cart_user)
        delete :destroy
      end

      after do
        sign_out(full_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "Does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
        expect(assigns(:cart).id).to eql(full_cart_id)
        expect(assigns(:cart)).to eq(full_cart)
      end

      it "completely clears out the cart" do
        #Validation of the test
        expect(full_cart_count).to be > 0
        #Actual test
        expect(assigns(:cart).cart_items.count).to eql(0)
      end
    end

    context "when the cart contains 100 items" do
      let!(:hundred_cart) {create(:cart, :with_100_mixed_items)}
      let!(:hundred_cart_user) { hundred_cart.user }
      let!(:hundred_cart_id) { hundred_cart.id }
      let!(:hundred_cart_count) {hundred_cart.cart_items.count}

      before do
        sign_in(hundred_cart_user)
        delete :destroy
      end

      after do
        sign_out(hundred_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "Does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
        expect(assigns(:cart).id).to eql(hundred_cart_id)
        expect(assigns(:cart)).to eq(hundred_cart)
      end

      it "completely clears out the cart" do
        #Validation of the test
        expect(hundred_cart_count).to be > 0
        #Actual test
        expect(assigns(:cart).cart_items.count).to eql(0)
      end
    end
  end

  describe "#destroy_active" do

    context "when the cart is empty" do
      render_views

      let!(:zero_cart) { create(:cart)}
      let!(:zero_cart_user) { zero_cart.user }
      let!(:zero_cart_count) { zero_cart.cart_items.count }
      let!(:zero_cart_id) { zero_cart.id }

      before do
        sign_in(zero_cart_user)
        delete :destroy_active
      end

      after do
        sign_out(zero_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
        expect(assigns(:cart).id).to eql(zero_cart_id)
        expect(assigns(:cart)).to eq(zero_cart)
      end

      it "ends with the cart completely empty" do
        #Validation of the test:
        expect(assigns(:cart).cart_items.count).to eql(zero_cart_count)

        #actual test:
        expect(assigns(:cart).cart_items.count).to eql(0)
      end
    end

    context "when the cart has every kind of item" do

      let!(:mixed_cart) {create(:cart, :with_basic_items, :with_free_items, :with_items_for_later, :with_unavailable_items, :with_incomplete_items, :with_expired_membership_items)}
      let!(:mixed_cart_id) { mixed_cart.id }
      let!(:mixed_cart_count) { mixed_cart.cart_items.count }
      let!(:mixed_cart_user) { mixed_cart.user }

      before do
        sign_in(mixed_cart_user)
        delete :destroy_active
      end

      after do
        sign_out(mixed_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "Does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
        expect(assigns(:cart).id).to eql(mixed_cart_id)
        expect(assigns(:cart)).to eq(mixed_cart)
      end

      it "clears the active items from the cart" do
        #Acquire test data
        actives_seen = 0
        laters_seen = 0
        assigns(:cart).cart_items.each {|i| i.later ? laters_seen +=1 : actives_seen +=1 }

        #Actual test
        expect(actives_seen).to eql(0)
        expect(mixed_cart_count - assigns(:cart).cart_items.count).to be > 0
        expect(laters_seen).to eql(assigns(:cart).cart_items.count)
      end
    end

    context "when the cart contains 100 mixed items" do

      let!(:hundred_mixed_cart) {create(:cart, :with_100_mixed_items)}
      let!(:hundred_mixed_user) { hundred_mixed_cart.user }
      let!(:hundred_mixed_cart_id) { hundred_mixed_cart.id }
      let!(:hundred_mixed_cart_count) {hundred_mixed_cart.cart_items.count}

      before do
        sign_in(hundred_mixed_user)
        delete :destroy_active
      end

      after do
        sign_out(hundred_mixed_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "Does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
      end

      it "clears the active items from the cart" do
        #Acquire test data
        actives_seen = 0
        laters_seen = 0

        assigns(:cart).cart_items.each {
          |i| i.later ? laters_seen +=1 : actives_seen +=1
        }

        #Actual test
        expect(actives_seen).to eql(0)
        expect(hundred_mixed_cart_count - assigns(:cart).cart_items.count).to be > 0
        expect(laters_seen).to eql(assigns(:cart).cart_items.count)
      end
    end
  end

  describe "#destroy_saved" do

    context "when the cart is empty" do
      render_views

      let!(:blank_cart) { create(:cart)}
      let!(:blank_cart_user) { blank_cart.user }
      let!(:blank_cart_count) { blank_cart.cart_items.count }
      let!(:blank_cart_id) { blank_cart.id }

      before do
        sign_in(blank_cart_user)
        delete :destroy_saved
      end

      after do
        sign_out(blank_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
        expect(assigns(:cart).id).to eql(blank_cart_id)
        expect(assigns(:cart)).to eq(blank_cart)
      end

      it "ends with the cart completely empty" do
        #Validation of the test:
        expect(assigns(:cart).cart_items.count).to eql(blank_cart_count)

        #actual test:
        expect(assigns(:cart).cart_items.count).to eql(0)
      end
    end

    context "when the cart has every kind of item" do
      render_views

      let!(:variety_cart) {create(:cart, :with_basic_items, :with_free_items, :with_items_for_later, :with_unavailable_items, :with_incomplete_items, :with_expired_membership_items)}
      let!(:variety_cart_id) { variety_cart.id }
      let!(:variety_cart_count) { variety_cart.cart_items.count }
      let!(:variety_cart_user) { variety_cart.user }

      before do
        sign_in(variety_cart_user)
        delete :destroy_saved
      end

      after do
        sign_out(variety_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "Does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
        expect(assigns(:cart).id).to eql(variety_cart_id)
        expect(assigns(:cart)).to eq(variety_cart)
      end

      it "clears the saved items from the cart" do
        #Acquire test data
        actives_seen = 0
        laters_seen = 0
        assigns(:cart).cart_items.each {
          |i| i.later ? laters_seen +=1 : actives_seen +=1
        }

        #Actual test
        expect(laters_seen).to eql(0)
        expect(variety_cart_count - assigns(:cart).cart_items.count).to be > 0
        expect(actives_seen).to eql(assigns(:cart).cart_items.count)
      end
    end

    context "when the cart contains 100 mixed items" do

      let!(:hundred_variety_cart) {create(:cart, :with_100_mixed_items)}
      let!(:hundred_variety_user) { hundred_variety_cart.user }
      let!(:hundred_variety_cart_id) { hundred_variety_cart.id }
      let!(:hundred_variety_cart_count) {hundred_variety_cart.cart_items.count}

      before do
        sign_in(hundred_variety_user)
        delete :destroy_saved
      end

      after do
        sign_out(hundred_variety_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "Does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
        expect(assigns(:cart).id).to eql(hundred_variety_cart_id)
        expect(assigns(:cart)).to eq(hundred_variety_cart)
      end

      it "clears the saved items from the cart" do
        #Acquire test data
        actives_seen = 0
        laters_seen = 0
        assigns(:cart).cart_items.each {
          |i| i.later ? laters_seen +=1 : actives_seen +=1
        }

        #Actual test
        expect(laters_seen).to eql(0)
        expect(hundred_variety_cart_count - assigns(:cart).cart_items.count).to be > 0
        expect(actives_seen).to eql(assigns(:cart).cart_items.count)
      end
    end
  end

  describe "PATCH #save_all_items_for_later" do
    context "when the cart is empty" do
      render_views
      let!(:hollow_cart) { create(:cart)}
      let!(:hollow_cart_user) { hollow_cart.user }
      let!(:hollow_cart_count) { hollow_cart.cart_items.count }
      let!(:hollow_cart_id) { hollow_cart.id }

      before do
        sign_in(hollow_cart_user)
        patch :save_all_items_for_later
      end

      after do
        sign_out(hollow_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
        expect(assigns(:cart).id).to eql(hollow_cart_id)
        expect(assigns(:cart)).to eq(hollow_cart)
      end

      it "ends with the cart completely empty" do
        #Validation of the test:
        expect(assigns(:cart).cart_items.count).to eql(hollow_cart_count)

        #actual test:
        expect(assigns(:cart).cart_items.count).to eql(0)
      end
    end

    context "when the cart has only basic items" do
      render_views

      let!(:basic_cart) {create(:cart, :with_basic_items)}
      let!(:basic_cart_id) { basic_cart.id }
      let!(:basic_cart_count) { basic_cart.cart_items.count }
      let!(:basic_cart_user) { basic_cart.user }
      let!(:basic_cart_now_items_count_initial) {basic_cart.cart_items.inject(0) {|nows, i|
        nows += 1 if i.later == false} || 0}
      let!(:basic_cart_later_items_count_initial) {basic_cart.cart_items.inject(0) {|laters, i|
        laters += 1 if i.later == true} || 0}

      before do
        sign_in(basic_cart_user)
        patch :save_all_items_for_later
      end

      after do
        sign_out(basic_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "Does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
        expect(assigns(:cart).id).to eql(basic_cart_id)
        expect(assigns(:cart)).to eq(basic_cart)
      end

      it "does not change the total number of CartItems in the cart" do
        expect(basic_cart_count).to eql(assigns(:cart).cart_items.count)
      end

      it "reduces the number of unsaved items in the cart to zero" do
        nows = 0
        assigns(:cart).cart_items.each {|i| nows += 1 if !i.later}

        expect(basic_cart_now_items_count_initial).to be > 0
        expect(nows).to eql(0)
      end

      it "increases the number of saved items by the number of previously-active items" do

        laters = 0
        assigns(:cart).cart_items.each {|i| laters += 1 if i.later}
        expect(laters).to eql(basic_cart_later_items_count_initial + basic_cart_now_items_count_initial)
      end

      it "results in a cart in which all items are saved items" do
        laters = 0
        assigns(:cart).cart_items.each {|i| laters += 1 if i.later}

        nows = 0
        assigns(:cart).cart_items.each {|i| nows += 1 if !i.later}

        expect(laters).to eql(assigns(:cart).cart_items.count)
        expect(nows).to eql(0)
      end
    end

    context "when the cart already contains saved items" do
      render_views
      let!(:all_saved_cart) {create(:cart, :with_items_for_later)}
      let!(:all_saved_cart_id) { all_saved_cart.id }
      let!(:all_saved_cart_count) { all_saved_cart.cart_items.count }
      let!(:all_saved_cart_user) { all_saved_cart.user }
      let!(:all_saved_cart_now_items_count_initial) {all_saved_cart.cart_items.inject(0) {|nows, i| nows += 1 if i.later == false}}
      let!(:all_saved_cart_later_items_count_initial) {all_saved_cart.cart_items.inject(0) {|laters, i| laters += 1 if i.later == true}}


      before do
        sign_in(all_saved_cart_user)
        patch :save_all_items_for_later
      end

      after do
        sign_out(all_saved_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "Does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
        expect(assigns(:cart).id).to eql(all_saved_cart_id)
        expect(assigns(:cart)).to eq(all_saved_cart)
      end

      it "does not change the total number of CartItems in the cart" do
        expect(all_saved_cart_count).to eql(assigns(:cart).cart_items.count)
      end

      it "results in a cart in which no items that are not saved for later" do
        nows = 0
        all_saved_cart.cart_items.each {|i| nows += 1 if !i.later}
        expect(nows).to eql(0)
      end

      it "results in a cart in which all items are saved items" do
        laters = 0
        all_saved_cart.cart_items.each {|i| laters += 1 if i.later}
        expect(laters).to eql(assigns(:cart).cart_items.count)
      end
    end

    context "when the cart contains difficult-to-process items" do

      let!(:problem_cart) {create(:cart, :with_all_problematic_items)}
      let!(:problem_cart_id) { problem_cart.id }
      let!(:problem_cart_count) { problem_cart.cart_items.count }
      let!(:problem_cart_user) { problem_cart.user }
      let!(:problem_cart_now_items_count_initial) {problem_cart.cart_items.inject(0) {|nows, i| nows += 1 if i.later == false} || 0}
      let!(:problem_cart_later_items_count_initial) {problem_cart.cart_items.inject(0) {|laters, i| laters += 1 if i.later == true} || 0}

      before do
        sign_in(problem_cart_user)
        patch :save_all_items_for_later
      end

      after do
        sign_out(problem_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "Does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
        expect(assigns(:cart).id).to eql(problem_cart_id)
        expect(assigns(:cart)).to eq(problem_cart)
      end

      it "does not change the total number of CartItems in the cart" do
        expect(problem_cart_count).to eql(assigns(:cart).cart_items.count)
      end

      it "reduces the number of unsaved items in the cart to zero" do
        nows = 0
        assigns(:cart).cart_items.each {|i| nows += 1 if !i.later}

        expect(problem_cart_now_items_count_initial).to be > 0

        expect(problem_cart_now_items_count_initial).to be > nows

        expect(nows).to eql(0)
      end

      it "increases the number of saved items by the number of previously-active items" do
        laters = 0
        assigns(:cart).cart_items.each {|i| laters += 1 if i.later}
        expect(problem_cart_later_items_count_initial + problem_cart_now_items_count_initial).to eql(laters)
      end

      it "results in a cart in which all items are saved items" do
        nows_seen = false
        assigns(:cart).cart_items.each {|i| nows_seen = true if !i.later}
        expect(nows_seen).to eql(false)
      end
    end

    context "when the cart contains 100 items" do
      let!(:century_cart) {create(:cart, :with_100_mixed_items)}
      let!(:century_cart_id) { century_cart.id }
      let!(:century_cart_count) { century_cart.cart_items.count }
      let!(:century_cart_user) { century_cart.user }

      before do
        sign_in(century_cart_user)
        patch :save_all_items_for_later
      end

      after do
        sign_out(century_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "Does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
        expect(assigns(:cart).id).to eql(century_cart_id)
        expect(assigns(:cart)).to eq(century_cart)
      end

      it "does not change the total number of CartItems in the cart" do
        expect(century_cart_count).to eql(assigns(:cart).cart_items.count)
      end

      it "reduces the number of unsaved items in the cart to zero" do
        now_items = 0
        assigns(:cart).cart_items.each {|i| now_items += 1 if !i.later}
        expect(now_items).to eql(0)
      end

      it "results in a cart in which all items are saved items" do
        later_items = 0
        assigns(:cart).cart_items.each {|i| later_items += 1 if i.later}
        expect(later_items).to eql(assigns(:cart).cart_items.count)
      end
    end
  end

  describe "PATCH #move_all_saved_items_to_cart" do
    context "when the cart is empty" do
      render_views

      let!(:e_cart) {create(:cart)}
      let!(:e_cart_id) { e_cart.id }
      let!(:e_cart_count) { e_cart.cart_items.count }
      let!(:e_cart_user) { e_cart.user }

      before do
        sign_in(e_cart_user)
        patch :move_all_saved_items_to_cart
      end

      after do
        sign_out(e_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "sets a flash notice about not finding any saved items" do
        expect(subject).to set_flash[:notice].to(/no saved/i)
      end

      it "Does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
        expect(assigns(:cart).id).to eql(e_cart_id)
        expect(assigns(:cart)).to eq(e_cart)
      end

      it "does not change the total number of CartItems in the cart" do
        expect(e_cart_count).to eql(0)
        expect(e_cart_count).to eql(assigns(:cart).cart_items.count)
      end
    end

    context "when the cart starts with only saved items" do
      render_views

      let!(:l_cart) {create(:cart, :with_items_for_later)}
      let!(:l_cart_id) { l_cart.id }
      let!(:l_cart_count) { l_cart.cart_items.count }
      let!(:l_cart_user) { l_cart.user }
      let!(:l_cart_now_items_count_initial) {l_cart.cart_items.inject(0) {|nows, i|
       nows += 1 if i.later == false} || 0}
      let!(:l_cart_later_items_count_initial) {l_cart.cart_items.inject(0) {|laters, i|
       laters += 1 if i.later == true} || 0}

      before do
        sign_in(l_cart_user)
        patch :move_all_saved_items_to_cart
      end

      after do
        sign_out(l_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
        expect(subject).to set_flash[:notice].to(/successfully/)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "Does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
        expect(assigns(:cart).id).to eql(l_cart_id)
        expect(assigns(:cart)).to eq(l_cart)
      end

      it "does not change the total number of CartItems in the cart" do
        expect(l_cart_count).to eql(assigns(:cart).cart_items.count)
      end

      it "reduces the number of saved items in the cart to zero" do
        laters = 0
        assigns(:cart).cart_items.each {|i| laters += 1 if i.later}

        expect(l_cart_later_items_count_initial).to be > 0
        expect(laters).to eql(0)
      end

      it "increases the number of saved items by the number of previously-active items" do
        nows = 0
        assigns(:cart).cart_items.each {|i| nows += 1 if !i.later}
        expect(nows).to eql(l_cart_later_items_count_initial + l_cart_now_items_count_initial)
      end

      it "results in a cart in which there are no saved items" do
        laters = 0
        assigns(:cart).cart_items.each {|i| laters += 1 if i.later}

        nows = 0
        assigns(:cart).cart_items.each {|i| nows += 1 if !i.later}

        expect(nows).to eql(assigns(:cart).cart_items.count)
        expect(laters).to eql(0)
      end
    end

    context "when the cart contains 100 items" do

      let!(:c_cart) {create(:cart, :with_100_mixed_items)}
      let!(:c_cart_id) { c_cart.id }
      let!(:c_cart_count) { c_cart.cart_items.count }
      let!(:c_cart_user) { c_cart.user }

      before do
        sign_in(c_cart_user)
        patch :move_all_saved_items_to_cart
      end

      after do
        sign_out(c_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
        expect(subject).to set_flash[:notice].to(/successfully moved/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "Does not destroy the Cart object" do
        expect(assigns(:cart)).not_to be_nil
        expect(assigns(:cart)).to be
        expect(assigns(:cart).id).to eql(c_cart_id)
        expect(assigns(:cart)).to eq(c_cart)
      end

      it "does not change the total number of CartItems in the cart" do
        expect(c_cart_count).to eql(assigns(:cart).cart_items.count)
      end

      it "results in a cart with zero saved items" do
        laters = 0
        assigns(:cart).cart_items.each {|i| laters += 1 if i.later}
        expect(laters).to eql(0)
      end

      it "results in a cart in which all items are in the active part of the cart" do
        laters = 0
        assigns(:cart).cart_items.each {|i| laters += 1 if i.later}
        nows = 0
        assigns(:cart).cart_items.each {|i| nows += 1 if !i.later}
        expect(nows).to eql(assigns(:cart).cart_items.count)
        expect(laters).to eql(0)
      end
    end
  end

  describe "#verify_all_items_availability" do

    context "when the cart contains only basic items" do
      render_views

      let!(:bas_cart) {create(:cart, :with_basic_items)}
      let!(:bas_cart_id) { bas_cart.id }
      let!(:bas_cart_count) { bas_cart.cart_items.count }
      let!(:bas_cart_user) { bas_cart.user }
      let!(:bas_cart_avail_count_initial) {bas_cart.cart_items.inject(0) {|avails, i|
       avails += 1 if i.available == true} || 0}

      before do
        sign_in(bas_cart_user)
        patch :verify_all_items_availability
      end

      after do
        sign_out(bas_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
        expect(subject).not_to set_flash[:alert]
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "does not change the total number of CartItems in the cart" do
        expect(bas_cart_count).to eql(assigns(:cart).cart_items.count)
      end

      it "does not change the number of available items in the cart" do
        avails = 0
        assigns(:cart).cart_items.each {|i| avails += 1 if i.available}
        expect(avails).to eql(bas_cart_avail_count_initial)
      end
    end

    context "when the cart contains only expired items" do
      render_views

      let!(:exp_cart) {create(:cart, :with_expired_membership_items)}
      let!(:exp_cart_id) { exp_cart.id }
      let!(:exp_cart_count) { exp_cart.cart_items.count }
      let!(:exp_cart_user) { exp_cart.user }
      let!(:exp_cart_avail_count_initial) {exp_cart.cart_items.inject(0) {|avails, i|
       avails += 1 if i.available == true} || 0}

      before do
        sign_in(exp_cart_user)
        patch :verify_all_items_availability
      end

      after do
        sign_out(exp_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert]
      end

      it "does not change the total number of CartItems in the cart" do
        expect(exp_cart_count).to eql(assigns(:cart).cart_items.count)
      end

      it "reduces the number of items in the cart marked 'available' to zero." do
        avails = 0
        assigns(:cart).cart_items.each {|i| avails += 1 if i.available}
        expect(avails).to be < exp_cart_avail_count_initial
        expect(avails).to eql(0)
      end
    end

    context "when the cart contains a mix of problematic items" do
      render_views
      let!(:prob_cart) {create(:cart, :with_all_problematic_items)}
      let!(:prob_cart_id) { prob_cart.id }
      let!(:prob_cart_count) { prob_cart.cart_items.count }
      let!(:prob_cart_user) { prob_cart.user }
      let!(:prob_cart_avail_count_initial) {prob_cart.cart_items.inject(0) {|avails, i|
       avails += 1 if i.available == true} || 0}

      before do
        sign_in(prob_cart_user)
        patch :verify_all_items_availability
      end

      after do
        sign_out(prob_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert]
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "does not change the total number of CartItems in the cart" do
        expect(prob_cart_count).to eql(assigns(:cart).cart_items.count)
      end

      it "Reduces the number of available items in the cart to zero" do
        avails = 0
        assigns(:cart).cart_items.each {|i| avails += 1 if i.available}
        expect(avails).to be < prob_cart_avail_count_initial
        expect(avails).to eql(0)
      end
    end

    context "when the cart contains a mix of problematic and non-problematic items" do
      render_views
      let!(:assorted_cart) {create(:cart, :with_all_problematic_items, :with_free_items, :with_basic_items)}
      let!(:assorted_cart_id) { assorted_cart.id }
      let!(:assorted_cart_count) { assorted_cart.cart_items.count }
      let!(:assorted_cart_user) { assorted_cart.user }
      let!(:assorted_cart_avail_count_initial) {assorted_cart.cart_items.inject(0) {|avails, i|
       avails += 1 if i.available == true} || 0}

      before do
        sign_in(assorted_cart_user)
        patch :verify_all_items_availability
      end

      after do
        sign_out(assorted_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert]
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "does not change the total number of CartItems in the cart" do
        expect(assorted_cart_count).to eql(assigns(:cart).cart_items.count)
      end

      it "Reduces the number of available items in the cart, but not to zero" do
        avails = 0
        assigns(:cart).cart_items.each {|i| avails += 1 if i.available}
        expect(avails).to be < assorted_cart_avail_count_initial
        expect(avails).to be > 0
      end
    end

    xcontext "when the cart contains 100 items" do
      let!(:hundo_cart) {create(:cart, :with_100_mixed_items)}
      let!(:hundo_cart_id) { hundo_cart.id }
      let!(:hundo_cart_count) { hundo_cart.cart_items.count }
      let!(:hundo_cart_user) { hundo_cart.user }

      before do
        sign_in(hundo_cart_user)
        patch :verify_all_items_availability
      end

      after do
        sign_out(hundo_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert]
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "does not change the total number of CartItems in the cart" do
        expect(hundo_cart_count).to eql(assigns(:cart).cart_items.count)
      end
    end
  end

  describe "DELETE #remove_single_item" do
    context "when the item is basic" do
      render_views

      let(:bsc_cart) { create(:cart, :with_basic_items) }
      let(:bsc_cart_id) { bsc_cart.id }
      let(:bsc_cart_user) { bsc_cart.user }
      let(:bsc_item) { bsc_cart.cart_items.sample }
      let(:bsc_item_id) { bsc_item.id }

      before do
        sign_in(bsc_cart_user)
        delete :remove_single_item, params: {
          :id => bsc_item_id
        }
      end

      after do
        sign_out(bsc_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about succeeding" do
        expect(subject).to set_flash[:notice].to(/successfully/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "removes the targeted item from the cart" do
        found_cart_items = assigns(:cart).cart_items.select {|i| i.id == bsc_item_id}

        expect(found_cart_items).to be_empty
      end

      it "removes the targeted item from the database" do
        found_database_items = CartItem.where(id: bsc_item_id)
        expect(found_database_items).to be_empty
      end
    end

    context "when the item is saved-for-later" do
      let(:sfl_cart) { create(:cart, :with_items_for_later) }
      let(:sfl_cart_id) { sfl_cart.id }
      let(:sfl_cart_user) { sfl_cart.user }
      let(:sfl_item) { sfl_cart.cart_items.sample }
      let(:sfl_item_id) { sfl_item.id }

      let(:sfl_cart_later_count_initial) {sfl_cart.cart_items.inject(0) {|laters, i|
       laters += 1 if i.later == true} || 0}

      before do
        sign_in(sfl_cart_user)
        delete :remove_single_item, params: {
          :id => sfl_item_id
        }
      end

      after do
        sign_out(sfl_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about succeeding" do
        expect(subject).to set_flash[:notice].to(/successfully/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "removes the targeted item from the cart" do
        found_cart_items = assigns(:cart).cart_items.select {|i| i.id == sfl_item_id}
        expect(found_cart_items).to be_empty
      end

      it "reduces the number of items in the cart that are saved for later by one" do
        laters = 0
        assigns(:cart).cart_items.each {|i| laters += 1 if i.later }
        expect(laters).to eql(sfl_cart_later_count_initial - 1)
      end

      it "removes the targeted item from the database" do
        found_database_items = CartItem.where(id: sfl_item_id)
        expect(found_database_items).to be_empty
      end
    end

    context "when the item is expired" do
      let(:ex_cart) { create(:cart, :with_expired_membership_items) }
      let(:ex_cart_id) { ex_cart.id }
      let(:ex_cart_user) { ex_cart.user }
      let(:ex_item) { ex_cart.cart_items.sample }
      let(:ex_item_id) { ex_item.id }

      before do
        sign_in(ex_cart_user)
        delete :remove_single_item, params: {
          :id => ex_item_id
        }
      end

      after do
        sign_out(ex_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about succeeding" do
        expect(subject).to set_flash[:notice].to(/successfully/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "removes the targeted item from the cart" do
        found_cart_items = assigns(:cart).cart_items.select {|i| i.id == ex_item_id}
        expect(found_cart_items).to be_empty
      end

      it "removes the targeted item from the database" do
        found_database_items = CartItem.where(id: ex_item_id)
        expect(found_database_items).to be_empty
      end
    end

    context "when the items's item_name_memo doesn't match its acquirable's name" do
      let(:altn_cart) { create(:cart, :with_altered_name_items) }
      let(:altn_cart_id) { altn_cart.id }
      let(:altn_cart_user) { altn_cart.user }
      let(:altn_item) { altn_cart.cart_items.sample }
      let(:altn_item_id) { altn_item.id }

      before do
        sign_in(altn_cart_user)

        delete :remove_single_item, params: {
          :id => altn_item_id
        }
      end

      after do
        sign_out(altn_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about succeeding" do
        expect(subject).to set_flash[:notice].to(/successfully/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "removes the targeted item from the database" do
        found_database_items = CartItem.where(id: altn_item_id)
        expect(found_database_items).to be_empty
      end
    end

    context "when the cart contains 100 items" do
      let(:benj_cart) { create(:cart, :with_100_mixed_items) }
      let(:benj_cart_id) { benj_cart.id }
      let(:benj_cart_user) { benj_cart.user }
      let(:benj_item) { benj_cart.cart_items.sample }
      let(:benj_item_id) { benj_item.id }

      before do
        sign_in(benj_cart_user)
        delete :remove_single_item, params: {
          :id => benj_item_id
        }
      end

      after do
        sign_out(benj_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about succeeding" do
        expect(subject).to set_flash[:notice].to(/successfully/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "removes the targeted item from the cart" do
        found_cart_items = assigns(:cart).cart_items.select {|i| i.id == benj_item_id}
        expect(found_cart_items).to be_empty
      end

      it "removes the targeted item from the database" do
        found_database_items = CartItem.where(id: benj_item_id)
        expect(found_database_items).to be_empty
      end
    end

    context "when the item is not in the user's cart" do
      let(:unremarkable_cart) { create(:cart, :with_basic_items) }
      let(:unremarkable_cart_id) { unremarkable_cart.id }
      let(:unremarkable_cart_count) { unremarkable_cart.cart_items.count }
      let(:unremarkable_cart_user) { unremarkable_cart.user }

      let(:nowhere_cart) {create(:cart, :with_basic_items)}
      let(:item_from_nowhere) {nowhere_cart.cart_items.sample}
      let(:item_from_nowhere_id) {item_from_nowhere.id}
      let(:item_from_nowhere_cart) {item_from_nowhere.cart}

      before do
        sign_in(unremarkable_cart_user)
        delete :remove_single_item, params: {
          :id => item_from_nowhere_id
        }
      end

      after do
        sign_out(unremarkable_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about not recognizing the item" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "Does not reduce the number of items in the cart" do
        expect(unremarkable_cart_count).to eql(assigns(:cart).cart_items.count)
      end

      it "Does not change the item's original cart association" do
        expect(item_from_nowhere_cart.id).not_to eql(assigns(:cart).id)
      end

      it "Does not remove the targeted item from the database" do
        found_database_items = CartItem.where(id: item_from_nowhere_id)
        expect(found_database_items).not_to be_empty
      end
    end

    context "when the item has already been removed" do
      let(:meh_cart) { create(:cart, :with_basic_items) }
      let(:meh_cart_id) { meh_cart.id }
      let(:meh_cart_user) { meh_cart.user }
      let(:doomed_item) {meh_cart.cart_items.sample}
      let(:doomed_item_id) {doomed_item.id}
      let(:total_cart_items) {CartItem.count}
      let(:meh_cart_count) { meh_cart.cart_items.count }

      before do
        doomed_item.destroy
        meh_cart.reload
        meh_cart_count = meh_cart.cart_items.count
        total_cart_items = CartItem.count
        sign_in(meh_cart_user)
        delete :remove_single_item, params: {
          :id => doomed_item_id
        }
      end

      after do
        sign_out(meh_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about not recognizing the item" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "Does not reduce the number of items in the cart" do
        expect(meh_cart_count).to eql(assigns(:cart).cart_items.count)
      end

      it "Does not reduce the number of CartItems in the database" do
        expect(total_cart_items).to eql(CartItem.count)
      end
    end
  end

  describe "PATCH verify_single_item_availability" do

    context "when the item is basic" do
      render_views

      let(:bbb_cart) { create(:cart, :with_basic_items) }
      let(:bbb_cart_user) { bbb_cart.user }
      let(:bbb_item) { bbb_cart.cart_items.sample }
      let(:bbb_item_id) { bbb_item.id }

      before do
        sign_in(bbb_cart_user)
        patch :verify_single_item_availability, params: {
          :id => bbb_item_id
        }
      end

      after do
        sign_out(bbb_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about the item being available" do
        expect(subject).to set_flash[:notice].to(/good news/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'available' attribute set to true" do
        expect(assigns(:target_item).available).to eql(true)
      end
    end

    context "when the item is saved-for-later" do
      let(:lates_cart) { create(:cart, :with_items_for_later) }
      let(:lates_cart_user) { lates_cart.user }
      let(:lates_item) { lates_cart.cart_items.sample }
      let(:lates_item_id) { lates_item.id }

      before do
        sign_in(lates_cart_user)
        patch :verify_single_item_availability, params: {
          :id => lates_item_id
        }
      end

      after do
        sign_out(lates_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a positive flash notice" do
        expect(subject).to set_flash[:notice].to(/good news/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'available' attribute set to true" do
        expect(assigns(:target_item).available).to eql(true)
      end
    end

    context "when the item is expired" do
      let(:expi_cart) { create(:cart, :with_expired_membership_items) }
      let(:expi_cart_user) { expi_cart.user }
      let(:expi_item) { expi_cart.cart_items.sample }
      let(:expi_item_id) { expi_item.id }
      let(:expi_item_available) {expi_item.available}

      before do
        sign_in(expi_cart_user)
        patch :verify_single_item_availability, params: {
          :id => expi_item_id
        }
      end

      after do
        sign_out(expi_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'available' attribute changed to false" do
        expect(expi_item_available).to eql(true)
        expect(assigns(:target_item).available).to eql(false)
      end
    end

    context "when the items's item_name_memo doesn't match its acquirable's name" do
      let(:altered_n_cart) { create(:cart, :with_altered_name_items) }
      let(:altered_n_cart_user) { altered_n_cart.user }
      let(:altered_n_item) { altered_n_cart.cart_items.sample }
      let(:altered_n_item_id) { altered_n_item.id }
      let(:altered_n_item_available) {altered_n_item.available}

      before do
        sign_in(altered_n_cart_user)
        patch :verify_single_item_availability, params: {
          :id => altered_n_item_id
        }
      end

      after do
        sign_out(altered_n_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'available' attribute changed to false" do
        expect(altered_n_item_available).to eql(true)
        expect(assigns(:target_item).available).to eql(false)
      end
    end

    context "when the item's item_price_memo doesn't match its acquirable's price" do

      let(:altered_p_cart) { create(:cart, :with_altered_price_items) }
      let(:altered_p_cart_user) { altered_p_cart.user }
      let(:altered_p_item) { altered_p_cart.cart_items.sample }
      let(:altered_p_item_id) { altered_p_item.id }
      let(:altered_p_item_available) {altered_p_item.available}

      before do
        sign_in(altered_p_cart_user)
        patch :verify_single_item_availability, params: {
          :id => altered_p_item_id
        }
      end

      after do
        sign_out(altered_p_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'available' attribute changed to false" do
        expect(altered_p_item_available).to eql(true)
        expect(assigns(:target_item).available).to eql(false)
      end
    end

    context "when the item has an unknown kind" do
      let(:unknown_k_cart) { create(:cart, :with_unknown_kind_items) }
      let(:unknown_k_cart_user) { unknown_k_cart.user }
      let(:unknown_k_item) { unknown_k_cart.cart_items.sample }
      let(:unknown_k_item_id) { unknown_k_item.id }
      let(:unknown_k_item_available) {unknown_k_item.available}

      before do
        sign_in(unknown_k_cart_user)
        patch :verify_single_item_availability, params: {
          :id => unknown_k_item_id
        }
      end

      after do
        sign_out(unknown_k_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'available' attribute changed to false" do
        expect(unknown_k_item_available).to eql(true)
        expect(assigns(:target_item).available).to eql(false)
      end
    end

    context "when the item is already marked unavailable" do
      let(:unav_cart) { create(:cart, :with_unavailable_items) }
      let(:unav_cart_user) { unav_cart.user }
      let(:unav_item) { unav_cart.cart_items.sample }
      let(:unav_item_id) { unav_item.id }
      let(:unav_item_available) {unav_item.available}

      before do
        sign_in(unav_cart_user)
        patch :verify_single_item_availability, params: {
          :id => unav_item_id
        }
      end

      after do
        sign_out(unav_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'available' remain set to false" do
        expect(unav_item_available).to eql(false)
        expect(assigns(:target_item).available).to eql(false)
      end
    end

    context "when the item is not in the user's cart" do
      let(:whatevs_cart) { create(:cart, :with_basic_items) }
      let(:whatevs_cart_id) { whatevs_cart.id }
      let(:whatevs_cart_count) { whatevs_cart.cart_items.count }
      let(:whatevs_cart_user) { whatevs_cart.user }

      let(:extraneous_cart) { create(:cart, :with_basic_items) }
      let(:extraneous_item) {extraneous_cart.cart_items.sample}
      let(:extraneous_item_id) {extraneous_item.id}
      let(:extraneous_item_availability) { extraneous_item.available}

      before do
        sign_in(whatevs_cart_user)
        patch :verify_single_item_availability, params: {
          :id => extraneous_item_id
        }
      end

      after do
        sign_out(whatevs_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "does not change the value of the item's 'available' attribute" do
        expect(extraneous_item_availability).to eql(CartItem.find_by(id: extraneous_item_id).available)
      end

      it "does not assign a value assigned to the @target_item instance variable" do
        expect(assigns(:target_item)).to be_nil
      end
    end

    context "when the item no longer exists" do

      let(:plain_cart) { create(:cart, :with_expired_membership_items) }
      let(:plain_cart_id) { plain_cart.id }
      let(:plain_cart_user) { plain_cart.user }
      let(:condemned_item) {plain_cart.cart_items.sample}
      let(:condemned_item_id) {condemned_item.id}
      let(:condemned_item_availability) {condemned_item.available}

      before do
        condemned_item.destroy
        plain_cart.reload
        sign_in(plain_cart_user)
        patch :verify_single_item_availability, params: {
          :id => condemned_item_id
        }
      end

      after do
        sign_out(plain_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "does not assign a value assigned to the @target_item instance variable" do
        expect(assigns(:target_item)).to be_nil
      end
    end

    context "when the item is marked incomplete" do
      let(:incom_cart) { create(:cart, :with_incomplete_items) }
      let(:incom_cart_user) { incom_cart.user }
      let(:incom_item) { incom_cart.cart_items.sample }
      let(:incom_item_id) { incom_item.id }
      let(:incom_item_available) {incom_item.available}

      before do
        sign_in(incom_cart_user)
        patch :verify_single_item_availability, params: {
          :id => incom_item_id
        }
      end

      after do
        sign_out(incom_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        pending
        expect(subject).to set_flash[:alert].to(/no longer/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'available' attribute changed to false" do
        pending
        expect(incom_item_available).to eql(true)
        expect(assigns(:target_item).available).to eql(false)
      end
    end
  end

  describe "PATCH #save_item_for_later" do
    context "when the item is basic" do
      render_views

      let(:bbbb_cart) { create(:cart, :with_basic_items) }
      let(:bbbb_cart_user) { bbbb_cart.user }
      let(:bbbb_item) { bbbb_cart.cart_items.sample }
      let(:bbbb_item_id) { bbbb_item.id }
      let(:bbbb_item_later) { bbbb_item.later }

      before do
        sign_in(bbbb_cart_user)
        patch :save_item_for_later, params: {
          :id => bbbb_item_id
        }
      end

      after do
        sign_out(bbbb_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'later' attribute changed to true" do
        expect(bbbb_item_later).to eql(false)
        expect(assigns(:target_item).later).to eql(true)
      end
    end

    context "when the item is already saved-for-later" do
      let(:laters_cart) { create(:cart, :with_items_for_later) }
      let(:laters_cart_user) { laters_cart.user }
      let(:laters_item) { laters_cart.cart_items.sample }
      let(:laters_item_id) { laters_item.id }
      let(:laters_item_later) { laters_item.later }

      before do
        sign_in(laters_cart_user)
        patch :save_item_for_later, params: {
          :id => laters_item_id
        }
      end

      after do
        sign_out(laters_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "does not change the item's later attribute's value of true" do
        expect(laters_item_later).to eql(true)
        expect(assigns(:target_item).later).to eql(laters_item_later)
      end
    end

    context "when the item is expired" do
      let(:expir_cart) { create(:cart, :with_expired_membership_items) }
      let(:expir_cart_user) { expir_cart.user }
      let(:expir_item) { expir_cart.cart_items.sample }
      let(:expir_item_id) { expir_item.id }
      let(:expir_item_later) {expir_item.later}

      before do
        sign_in(expir_cart_user)
        patch :save_item_for_later, params: {
          :id => expir_item_id
        }
      end

      after do
        sign_out(expir_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "changes the item's later attribute's value to true" do
        expect(expir_item_later).to eql(false)
        expect(assigns(:target_item).later).to eql(true)
      end
    end

    context "when the items's item_name_memo doesn't match its acquirable's name" do
      let(:alt_n_cart) { create(:cart, :with_altered_name_items) }
      let(:alt_n_cart_user) { alt_n_cart.user }
      let(:alt_n_item) { alt_n_cart.cart_items.sample }
      let(:alt_n_item_id) { alt_n_item.id }
      let(:alt_n_item_later) {alt_n_item.later}

      before do
        sign_in(alt_n_cart_user)
        patch :save_item_for_later, params: {
          :id => alt_n_item_id
        }
      end

      after do
        sign_out(alt_n_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "change the item's 'later' attribute's value to true" do
        expect(alt_n_item_later).to eql(false)
        expect(assigns(:target_item).later).to eql(true)
      end
    end

    context "when the item's item_price_memo doesn't match its acquirable's price" do

      let(:alt_p_cart) { create(:cart, :with_altered_price_items) }
      let(:alt_p_cart_user) { alt_p_cart.user }
      let(:alt_p_item) { alt_p_cart.cart_items.sample }
      let(:alt_p_item_id) { alt_p_item.id }
      let(:alt_p_item_later) {alt_p_item.later}

      before do
        sign_in(alt_p_cart_user)
        patch :save_item_for_later, params: {
          :id => alt_p_item_id
        }
      end

      after do
        sign_out(alt_p_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:notice].to(/successfully/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'later' attribute's value changed to true" do
        expect(alt_p_item_later).to eql(false)
        expect(assigns(:target_item).later).to eql(true)
      end
    end

    context "when the item has an unknown kind" do
      let(:unk_k_cart) { create(:cart, :with_unknown_kind_items) }
      let(:unk_k_cart_user) { unk_k_cart.user }
      let(:unk_k_item) { unk_k_cart.cart_items.sample }
      let(:unk_k_item_id) { unk_k_item.id }
      let(:unk_k_item_later) {unk_k_item.later}

      before do
        sign_in(unk_k_cart_user)
        patch :save_item_for_later, params: {
          :id => unk_k_item_id
        }
      end

      after do
        sign_out(unk_k_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about the change being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'later' attribute's value changed to true" do
        expect(unk_k_item_later).to eql(false)
        expect(assigns(:target_item).later).to eql(true)
      end
    end

    context "when the item is marked unavailable" do
      let(:unavl_cart) { create(:cart, :with_unavailable_items) }
      let(:unavl_cart_user) { unavl_cart.user }
      let(:unavl_item) { unavl_cart.cart_items.sample }
      let(:unavl_item_id) { unavl_item.id }
      let(:unavl_item_later) {unavl_item.later}

      before do
        sign_in(unavl_cart_user)
        patch :save_item_for_later, params: {
          :id => unavl_item_id
        }
      end

      after do
        sign_out(unavl_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about the operationn being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'later' attribute's value changed to true" do
        expect(unavl_item_later).to eql(false)
        expect(assigns(:target_item).later).to eql(true)
      end
    end

    context "when the item is not in the user's cart" do
      let(:pre_latered_cart) { create(:cart, :with_items_for_later) }
      let(:pre_latered_cart_user) { pre_latered_cart.user }

      let(:external_cart) { create(:cart, :with_basic_items) }
      let(:external_item) { external_cart.cart_items.sample }
      let(:external_item_id) { external_item.id }
      let(:external_item_later) { external_item.later}

      before do
        sign_in(pre_latered_cart_user)
        patch :save_item_for_later, params: {
          :id => external_item_id
        }
      end

      after do
        sign_out(pre_latered_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "does not change the value of the item's 'later' attribute" do
        expect(external_item_later).to eql(false)
        expect(external_item_later).to eql(CartItem.find_by(id: external_item_id).later)
      end

      it "does not assign a value assigned to the @target_item instance variable" do
        expect(assigns(:target_item)).to be_nil
      end
    end

    context "when the item no longer exists" do

      let(:nominal_cart) { create(:cart, :with_basic_items) }
      let(:nominal_cart_user) { nominal_cart.user }
      let(:nominal_cart_later_items_seen_initial) { nominal_cart.cart_items.inject(0) {|laters, i|
       laters += 1 if i.later == true} || 0}

      let(:cancelled_item) {nominal_cart.cart_items.sample}
      let(:cancelled_item_id) {cancelled_item.id}

      before do
        cancelled_item.destroy
        nominal_cart.reload
        sign_in(nominal_cart_user)
        patch :save_item_for_later, params: {
          :id => cancelled_item_id
        }
      end

      after do
        sign_out(nominal_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "does not assign a value assigned to the @target_item instance variable" do
        expect(assigns(:target_item)).to be_nil
      end

      it "does not change the number of items in the cart with a value of true assigned to their later attribute" do
        laters_seen = 0
        assigns(:cart).cart_items.each {|i| laters_seen += 1 if i.later }
        expect(nominal_cart_later_items_seen_initial).to eql(laters_seen)
      end
    end

    context "when the item is marked incomplete" do
      let(:incompl_cart) { create(:cart, :with_incomplete_items) }
      let(:incompl_cart_user) { incompl_cart.user }
      let(:incompl_item) { incompl_cart.cart_items.sample }
      let(:incompl_item_id) { incompl_item.id }
      let(:incompl_item_later) {incompl_item.later}

      before do
        sign_in(incompl_cart_user)
        patch :save_item_for_later, params: {
          :id => incompl_item_id
        }
      end

      after do
        sign_out(incompl_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about the operation being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'later' attribute's value changed to true" do
        expect(incompl_item_later).to eql(false)
        expect(assigns(:target_item).later).to eql(true)
      end
    end
  end

  describe "PATCH #move_item_to_cart" do
    context "when the item is basic and saved for later" do
      let(:basic_laters_cart) { create(:cart, :with_items_for_later) }
      let(:basic_laters_cart_user) { basic_laters_cart.user }
      let(:basic_laters_item) { basic_laters_cart.cart_items.sample }
      let(:basic_laters_item_id) { basic_laters_item.id }
      let(:basic_laters_item_later) { basic_laters_item.later }

      before do
        sign_in(basic_laters_cart_user)
        patch :move_item_to_cart, params: {
          :id => basic_laters_item_id
        }
      end

      after do
        sign_out(basic_laters_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "Changes the item's later attribute's value to false" do
        expect(basic_laters_item_later).to eql(true)
        expect(assigns(:target_item).later).to eql(false)
      end
    end

    context "when the item is expired and saved for later" do
      let(:expir_later_cart) { create(:cart, :with_expired_saved_for_later_items) }
      let(:expir_later_cart_user) { expir_later_cart.user }
      let(:expir_later_item) { expir_later_cart.cart_items.sample }
      let(:expir_later_item_id) { expir_later_item.id }
      let(:expir_later_item_later) {expir_later_item.later}

      before do
        sign_in(expir_later_cart_user)
        patch :move_item_to_cart, params: {
          :id => expir_later_item_id
        }
      end

      after do
        sign_out(expir_later_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "changes the item's later attribute's value to false" do
        expect(expir_later_item_later).to eql(true)
        expect(assigns(:target_item).later).to eql(false)
      end
    end

    context "when the items's item_name_memo doesn't match its acquirable's name and it is saved for later" do
      let(:alt_n_saved_cart) { create(:cart, :with_name_altered_saved_for_later_items) }
      let(:alt_n_saved_cart_user) { alt_n_saved_cart.user }
      let(:alt_n_saved_item) { alt_n_saved_cart.cart_items.sample }
      let(:alt_n_saved_item_id) { alt_n_saved_item.id }
      let(:alt_n_saved_item_later) {alt_n_saved_item.later}

      before do
        sign_in(alt_n_saved_cart_user)
        patch :move_item_to_cart, params: {
          :id => alt_n_saved_item_id
        }
      end

      after do
        sign_out(alt_n_saved_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "change the item's 'later' attribute's value to false" do
        expect(alt_n_saved_item_later).to eql(true)
        expect(assigns(:target_item).later).to eql(false)
      end
    end

    context "when the item's item_price_memo doesn't match its acquirable's price and the item is saved for later" do

      let(:altered_p_saved_cart) { create(:cart, :with_price_altered_saved_for_later_items) }
      let(:altered_p_saved_cart_user) { altered_p_saved_cart.user }
      let(:altered_p_saved_item) { altered_p_saved_cart.cart_items.sample }
      let(:altered_p_saved_item_id) { altered_p_saved_item.id }
      let(:altered_p_saved_item_later) {altered_p_saved_item.later}

      before do
        sign_in(altered_p_saved_cart_user)
        patch :move_item_to_cart, params: {
          :id => altered_p_saved_item_id
        }
      end

      after do
        sign_out(altered_p_saved_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:notice].to(/successfully/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'later' attribute's value changed to false" do
        expect(altered_p_saved_item_later).to eql(true)
        expect(assigns(:target_item).later).to eql(false)
      end
    end

    context "when the item has an unknown kind and is saved for later" do
      let(:unk_k_saved_cart) { create(:cart, :with_unknown_kind_saved_for_later_items) }
      let(:unk_k_saved_cart_user) { unk_k_saved_cart.user }
      let(:unk_k_saved_item) { unk_k_saved_cart.cart_items.sample }
      let(:unk_k_saved_item_id) { unk_k_saved_item.id }
      let(:unk_k_saved_item_later) {unk_k_saved_item.later}

      before do
        sign_in(unk_k_saved_cart_user)
        patch :move_item_to_cart, params: {
          :id => unk_k_saved_item_id
        }
      end

      after do
        sign_out(unk_k_saved_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about the change being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'later' attribute's value changed to false" do
        expect(unk_k_saved_item_later).to eql(true)
        expect(assigns(:target_item).later).to eql(false)
      end
    end

    context "when the item is marked unavailable and is saved for later" do
      let(:unavl_saved_cart) { create(:cart, :with_unavailable_saved_for_later_items) }
      let(:unavl_saved_cart_user) { unavl_saved_cart.user }
      let(:unavl_saved_item) { unavl_saved_cart.cart_items.sample }
      let(:unavl_saved_item_id) { unavl_saved_item.id }
      let(:unavl_saved_item_later) {unavl_saved_item.later}

      before do
        sign_in(unavl_saved_cart_user)
        patch :move_item_to_cart, params: {
          :id => unavl_saved_item_id
        }
      end

      after do
        sign_out(unavl_saved_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about the operationn being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'later' attribute's value changed to false" do
        expect(unavl_saved_item_later).to eql(true)
        expect(assigns(:target_item).later).to eql(false)
      end
    end

    context "when the item is not in the user's cart" do
      let(:pre_l_cart) { create(:cart, :with_items_for_later) }
      let(:pre_l_cart_user) { pre_l_cart.user }
      let(:pre_l_cart_later_items_seen_initial) { pre_l_cart.cart_items.inject(0) {|laters, i|
       laters += 1 if i.later == true} || 0}

      let(:extern_cart) { create(:cart, :with_basic_items)}
      let(:extern_item) { extern_cart.cart_items.sample}
      let(:extern_item_id) { extern_item.id }
      let(:extern_item_later) { extern_item.later}

      before do
        extern_item.later = true
        extern_item.save
        extern_item_later = extern_item.later
        pre_l_cart.reload
        sign_in(pre_l_cart_user)
        patch :move_item_to_cart, params: {
          :id => extern_item_id
        }
      end

      after do
        sign_out(pre_l_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "does not assign a value assigned to the @target_item instance variable" do
        expect(assigns(:target_item)).to be_nil
      end

      it "does not change the value of the item's 'later' attribute, which is set to true" do
        expect(extern_item_later).to eql(true)
        expect(extern_item_later).to eql(CartItem.find_by(id: extern_item_id).later)
      end

      it "does not change the number of items that are saved for later in the cart" do
        laters_seen = 0
        assigns(:cart).cart_items.each {|i| laters_seen += 1 if i.later}
        expect(laters_seen).to eql(pre_l_cart_later_items_seen_initial)
      end
    end

    context "when the item no longer exists" do

      let(:nominal_later_cart) { create(:cart, :with_items_for_later) }
      let(:nominal_later_cart_user) { nominal_later_cart.user }
      let(:nominal_later_cart_later_items_seen_initial) { nominal_later_cart.cart_items.inject(0) {|laters, i|
       laters += 1 if i.later == true} || 0}

      let(:eliminated_item) {nominal_later_cart.cart_items.sample}
      let(:eliminated_item_id) {eliminated_item.id}
      let(:eliminated_item_later) {eliminated_item.later}

      before do
        eliminated_item.destroy
        nominal_later_cart.reload
        sign_in(nominal_later_cart_user)
        patch :move_item_to_cart, params: {
          :id => eliminated_item_id
        }
      end

      after do
        sign_out(nominal_later_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "does not assign a value assigned to the @target_item instance variable" do
        expect(assigns(:target_item)).to be_nil
      end

      it "does not change the number of items in the cart with a value of true assigned to their later attribute" do
        laters_seen = 0
        assigns(:cart).cart_items.each {|i| laters_seen += 1 if i.later }
        expect(nominal_later_cart_later_items_seen_initial).to eql(laters_seen)
      end
    end

    context "when the item is marked incomplete and saved" do
      let(:incompl_saved_cart) { create(:cart, :with_incomplete_saved_for_later_items) }
      let(:incompl_saved_cart_user) { incompl_saved_cart.user }
      let(:incompl_saved_item) { incompl_saved_cart.cart_items.sample }
      let(:incompl_saved_item_id) { incompl_saved_item.id }
      let(:incompl_saved_item_later) {incompl_saved_item.later}

      before do
        sign_in(incompl_saved_cart_user)
        patch :move_item_to_cart, params: {
          :id => incompl_saved_item_id
        }
      end

      after do
        sign_out(incompl_saved_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about the operation being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "ends with the target item having its 'later' attribute's value changed to false" do
        expect(incompl_saved_item_later).to eql(true)
        expect(assigns(:target_item).later).to eql(false)
      end
    end

    context "when the item is not saved for later initially" do

      let(:no_laters_cart) { create(:cart, :with_basic_items) }
      let(:no_laters_cart_user) { no_laters_cart.user }
      let(:no_laters_item) { no_laters_cart.cart_items.sample }
      let(:no_laters_item_id) { no_laters_item.id }
      let(:no_laters_item_later) { no_laters_item.later }

      before do
        sign_in(no_laters_cart_user)
        patch :move_item_to_cart, params: {
          :id => no_laters_item_id
        }
      end

      after do
        sign_out(no_laters_cart_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "sets a flash notice about being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i)
      end

      it "renders" do
        expect(subject).to render_template(:cart)
      end

      it "results in no change to the target item's 'later' attribute's value of false" do
        expect(no_laters_item_later).to eql(false)
        expect(assigns(:target_item).later).to eql(no_laters_item_later)
        expect(assigns(:target_item).later).to eql(false)
      end
    end
  end

  xdescribe "#submit_online_payment" do
    pending
  end

  ###### NOT IMPLEMENTED IN THE CONTROLLER YET:
  xdescribe "#edit_single_item" do
  end

  xdescribe "#update" do
  end

  xdescribe "#update_cart_info" do
    pending
  end

  xdescribe "#pay_with_cheque" do
    pending
  end
end
