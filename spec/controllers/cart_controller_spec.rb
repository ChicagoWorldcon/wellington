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
  #render_views

  let(:contact_model_key) { Claim.contact_strategy.to_s.underscore.to_sym }
  let(:contact_model)

  let!(:kidit) { create(:membership, :kidit) }
  let!(:adult) { create(:membership, :adult) }
  let!(:tuatara) { create(:membership, :tuatara)}

  let!(:offer_valid) { MembershipOffer.new(adult) }
  let!(:offer_expired) {MembershipOffer.new(tuatara)}
  let!(:offer_age_dependent) {MembershipOffer.new(kidit)}

  let!(:valid_contact_params) do
    FactoryBot.build(:chicago_contact).slice(
      :first_name,
      :last_name,
      :publication_format,
      :address_line_1,
      :country,
      :email,
    )
  end

  let!(:valid_contact_params_with_dob) do
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

  let!(:invalid_contact_params) do
    FactoryBot.build(:chicago_contact).slice(
      :first_name,
      :last_name,
      :publication_format,
      :country,
      :email
    )
  end

  let!(:stresstest_cart) {create(:cart, :with_100_mixed_items)}
  let!(:existing_stresstest_user) { stresstest_cart.user }

  let!(:hodgepodge_cart) {create(:cart, :with_basic_items, :with_free_items, :with_items_for_later, :with_unavailable_items, :with_incomplete_items, :with_expired_membership_items)}
  let!(:existing_hodgepodge_user) {hodgepodge_cart.user}

  let(:support_user) { create(:support)}

  xdescribe "#show" do
    context "when a first-time user is signed in" do
      render_views
      let(:naive_user) { create(:user)}
      before do
        sign_in(naive_user)
        get :show
      end
      after(:all) do
        sign_out(naive_user)
      end
      it "creates a cart for the new user" do
        expect(assigns(:cart)).to be_a(CartItem) #inverted

        # Why yes, as a matter of fact, this IS the worst sin
        # against controller-testing best practices ever!
        # Eventually, this will probably get removed to a
        # feature or request test.
        expect(assigns(:cart).user).not_to eql(naive_user) #inverted
        expect(assigns(:cart).cart_items.count).not_to eql(0) #inverted
      end
      it "renders" do
        expect(response).not_to have_http_status(:ok) #inverted
        expect(subject).not_to render_template(:cart) #inverted
      end
    end

    context "when a user with an existing cart is signed in" do
      before do
        sign_in(existing_hodgepodge_user)
        get :show
      end
      after(:all) do
        sign_out(existing_hodgepodge_user)
      end
      it "finds the user's cart" do
        expect(assigns(:cart)).not_to eq(hodgepodge_cart) #inverted
      end
      it "renders" do
        expect(response).not_to have_http_status(:ok) #inverted
      end
    end

    context "when a support user is signed in" do
      render_views
      before do
        sign_in(support_user)
        get :show
      end
      after(:all) do
        sign_out(support_user)
      end
      it "redirects to the root path" do
        expect(response).not_to have_http_status(:found) #inverted
        expect(response).not_to redirect_to(root_path) #inverted
      end
      it "sets a flash message about logging into your personal account to make personal purchases"  do
        expect(subject).not_to set_flash[:alert].to(/personal/) #inverted
      end
    end

    context "without sign-in" do
      before do
        get :show
      end

      it "redirects to the root path" do
        expect(response).not_to have_http_status(:found) #inverted
        expect(response).not_to redirect_to(root_path) #inverted
      end
    end
  end

  describe "#add_reservation_to_cart" do
    before(:all) do
      sign_in(existing_hodgepodge_user)
    end

    after(:all) do
      sign_out(existing_hodgepodge_user)
    end

    before(:each) do
      let!(starting_hodgepodge_cart_count) {hodgepodge_cart.cart_items.count}
    end

    context "when the membembership is active and the beneficiary has all the necessary info" do
      render_views
      before do
        post :add_reservation_to_cart, params: {
          contact_model_key => valid_contact_params_with_dob,
          :offer => offer_valid.hash
        }
      end
      it "succeeds" do
        expect(response).to have_http_status(:ok)
      end

      it "renders the cart template" do
        expect(subject).to render_template(:cart)
      end

      it "locates the user's cart" do
        expect(assigns(:cart)).to be_a(Cart)
        expect(assigns(:cart)).to eq(hodgepodge_cart)
        expect(assigns(:cart).user).to eq(existing_hodgepodge_user)
      end

      it "creates an offer object" do
        expect(assigns(:our_offer)).to be_a(MembershipOffer)
        expect(assigns(:our_offer)).to eq(offer_valid)
      end

      it "creates a contact object" do
        expect(assigns(:our_beneficiary)).to be_a(Claim.contact_strategy)
        expect(assigns(:our_beneficiary).first_name) to eq(valid_contact_params[:first_name])
      end

      it "populates the contact object's date_of_birth field with a date object" do
        expect(assigns(:our_beneficiary).date_of_birth).to be_a(Date)
      end

      it "creates a cart item" do
        expect(assigns(:our_cart_item)).to be_a(CartItem)
        expect(assigns(:our_cart_item).acquirable.name).to eq(offer_valid.membership.name)
        expect(assigns(:our_cart_item).benefitable.last_name).to eq(valid_contact_params[:last_name])
      end

      it "adds the new CartItem to the cart" do
        expect(assigns(:cart).cart_items.count).to eql(starting_hodgepodge_cart_count + 1)
        found_in_cart = assigns(:cart).cart_items.find {|i| i.id == assigns(:our_cart_item).id }
        expect(assigns(:our_cart_item)).to eq(found_in_cart)
      end
    end

    context "when there are issues with the beneficiary or the membership" do
      context "when the HTTP_REFERER has been set" do
        before(:each) do
          request.env['HTTP_REFERER'] = memberships_path
        end
        context "when the membership offer is expired" do
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

          it "sets a flash error about the offer being unavailable" do
             expect(subject).to set_flash[:error].to(/unavailable/)
          end

          it "sets a flash notice about not being able to add the membership to the cart" do
            # This might not happen.  It might redirect before this.
             expect(subject).to set_flash[:notice].to(/could not be added/)
          end

          it "sets a flash status of failure" do
            # This might not happen.  It might redirect before this.
             expect(subject).to set_flash[:notice].to(:failure)
          end

          it "sets some flash messages" do
            # This might not happen.  It might redirect before this.
            expect(subject).to set_flash[:messages]
          end

          it "does not add a new item to the cart" do
            expect(assigns(:cart).cart_items.count).to eql(starting_hodgepodge_cart_count)
          end
        end
      end

      context "when the HTTP_REFERER has not been set" do
        before(:each) do
          request.env['HTTP_REFERER'] = nil
        end

        context "when the beneficiary is invalid" do
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
            expect(subject).to set_flash[:error].to(/email/)
          end

          it "does not add the item to the cart" do
            expect(assigns(:cart).cart_items.count).to eql(starting_hodgepodge_cart_count)
          end
        end
      end

      context "when the beneficiary params do not include a date of birth" do
        it "leaves the contact object's date_of_birth field empty" do
          expect(assigns(:our_beneficiary).date_of_birth).to be_nil
        end
        context "when the membership requires a date of birth" do
          it "marks the item incomplete" do
            pending
            expect(assigns(:our_cart_item.incomplete).to eql(true))
          end
          it "adds the item to the cart" do
            pending
            expect(assigns(:cart).cart_items.count).to eql(starting_hodgepodge_cart_count + 1)
            expect(assigns(:our_cart_item).cart).to eq(assigns(:cart))
          end
        end
      end
    end
  end
  #
  # describe "#update_cart_info" do
  #   pending
  # end
  #
  # describe "#submit_online_payment" do
  #   pending
  # end
  #
  # describe "#pay_with_cheque" do
  #   pending
  # end
  #
  describe "#destroy" do

    context "when the cart is empty" do
      render_views
      before(:all) do
        let!(:empty_cart) { create(:cart)}
        let!(:empty_user) { empty_cart.user }
        let!(:empty_cart_count) { empty_cart.cart_items.count }
        let!(:empty_cart_id) { empty_cart.id }
        sign_in(empty_user)
        delete :destroy
      end

      after(:all) do
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
        expect(assigns(:cart)).not_To be_nil
        expect(assigns(:cart).id).to eql(empty_cart_id)
        expect(assigns(:cart)).to eq(empty_cart)
      end


      it "ends with the cart completely empty" do
        #Validation of the test:
        expect(assigns(:cart.cart_items.count).to eql(empty_cart_count)

        #actual test:
        expect(assigns(:cart.cart_items.count).to eql(0)
      end
    end

    context "when the cart has every kind of item" do
      render_views

      before(:all) do
        let!(:full_cart) {create(:cart, :with_basic_items, :with_free_items, :with_items_for_later, :with_unavailable_items, :with_incomplete_items, :with_expired_membership_items)}
        let!(:full_cart_count) { full_cart.cart_items.count }
        let!(:full_cart_user) { full_cart.user }
        let!(:full_cart_id) { full_cart.id }
        sign_in(full_cart_user)
      end

      after(:all) do
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

      before(:all) do
        let!(:hundred_cart) {create(:cart, :with_100_mixed_items)}
        let!(:hundred_cart_user) { hundred_cart.user }
        let!(:hundred_cart_id) { hundred_cart.id }
        let!(:hundred_cart_count) {full_cart.cart_items.count}
        sign_in(hundred_cart_user)
      end

      after(:all) do
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
        expect(full_cart_count).to be > 0
        #Actual test
        expect(assigns(:cart).cart_items.count).to eql(0)
      end
    end
  end

  describe "#destroy_active" do

    context "when the cart is empty" do
      render_views

      before(:all) do
        let!(:zero_cart) { create(:cart)}
        let!(:zero_cart_user) { zero_cart.user }
        let!(:zero_cart_count) { zero_cart.cart_items.count }
        let!(:zero_cart_id) { zero_cart.id }
        sign_in(zero_user)
        delete :destroy_active
      end

      after(:all) do
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
        expect(assigns(:cart.cart_items.count).to eql(zero_cart_count)

        #actual test:
        expect(assigns(:cart.cart_items.count).to eql(0)
      end
    end

    context "when the cart has every kind of item" do
      before(:all) do
        let!(:mixed_cart) {create(:cart, :with_basic_items, :with_free_items, :with_items_for_later, :with_unavailable_items, :with_incomplete_items, :with_expired_membership_items)}
        let!(:mixed_cart_id) { mixed_cart.id }
        let!(:mixed_cart_count) { mixed_cart.cart_items.count }
        let!(:mixed_cart_user) { mixed_cart.user }
        sign_in(mixed_cart_user)
        delete :destroy_active
      end

      after(:all) do
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
        assigns(:cart).cart_items.each {
          |i| i.later ? laters_seen +=1 : actives_seen +=1
        }

        #Actual test
        expect(actives_seen).to eql(0)
        expect(mixed_cart_count - assigns(:cart).cart_items.count).to be > 0
        expect(laters_seen).to eql(assigns(:cart).cart_items.count)
      end
    end

    context "when the cart contains 100 mixed items" do
      before(:all) do
        let!(:hundred_mixed_cart) {create(:cart, :with_100_mixed_items)}
        let!(:hundred_mixed_user) { hundred_mixed_cart.user }
        let!(:hundred_mixed_cart_id) { hundred_mixed_cart.id }
        let!(:hundred_mixed_cart_count) {hundred_mixed_cart.cart_items.count}
        sign_in(hundred_mixed_cart_user)
        delete :destroy_active
      end

      after(:all) do
        sign_out(hundred_mixed_cart_user)
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

      before(:all) do
        let!(:blank_cart) { create(:cart)}
        let!(:blank_cart_user) { blank_cart.user }
        let!(:blank_cart_count) { blank_cart.cart_items.count }
        let!(:blank_cart_id) { blank_cart.id }
        sign_in(blank_cart_user)
        delete :destroy_saved
      end

      after(:all) do
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
        expect(assigns(:cart.cart_items.count).to eql(blank_cart_count)

        #actual test:
        expect(assigns(:cart.cart_items.count).to eql(0)
      end
    end

    context "when the cart has every kind of item" do
      render_views
      before(:all) do
        let!(:variety_cart) {create(:cart, :with_basic_items, :with_free_items, :with_items_for_later, :with_unavailable_items, :with_incomplete_items, :with_expired_membership_items)}
        let!(:variety_cart_id) { variety_cart.id }
        let!(:variety_cart_count) { variety_cart.cart_items.count }
        let!(:variety_cart_user) { variety_cart.user }
        sign_in(variety_cart_user)
        delete :destroy_saved
      end

      after(:all) do
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
      before(:all) do
        let!(:hundred_variety_cart) {create(:cart, :with_100_mixed_items)}
        let!(:hundred_variety_user) { hundred_variety_cart.user }
        let!(:hundred_variety_cart_id) { hundred_variety_cart.id }
        let!(:hundred_variety_cart_count) {hundred_variety_cart.cart_items.count}
        sign_in(hundred_variety_cart_user)
        delete :destroy_saved
      end

      after(:all) do
        sign_out(hundred_variety_cart_user)
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
        expect(hundred_mixed_cart_count - assigns(:cart).cart_items.count).to be > 0
        expect(actives_seen).to eql(assigns(:cart).cart_items.count)
      end
    end
  end

  describe "PATCH #save_all_items_for_later" do
    context "when the cart is empty" do
      render_views

      before(:all) do
        let!(:hollow_cart) { create(:cart)}
        let!(:hollow_cart_user) { hollow_cart.user }
        let!(:hollow_cart_count) { hollow_cart.cart_items.count }
        let!(:hollow_cart_id) { hollow_cart.id }
        sign_in(hollow_cart_user)
        patch :save_all_items_for_later
      end

      after(:all) do
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
        expect(assigns(:cart.cart_items.count).to eql(hollow_cart_count)

        #actual test:
        expect(assigns(:cart.cart_items.count).to eql(0)
      end
    end

    context "when the cart has only basic items" do
      render_views
      before(:all) do
        let!(:basic_cart) {create(:cart, :with_basic_items)}
        let!(:basic_cart_id) { basic_cart.id }
        let!(:basic_cart_count) { basic_cart.cart_items.count }
        let!(:basic_cart_user) { basic_cart.user }
        let!(:basic_cart_now_items_count_initial) {basic_cart.cart_items.inject(0) {|nows, i| nows += 1 if i.later == false}}
        let!(:basic_cart_later_items_count_initial) {basic_cart.cart_items.inject(0) {|laters, i| laters += 1 if i.later == true}}
        sign_in(basic_cart_user)
        patch :save_all_items_for_later
        let!(:basic_cart_now_items_count_final) {basic_cart.cart_items.inject(0) {|nows, i| nows += 1 if i.later == false}}
        let!(:basic_cart_later_items_count_final) {basic_cart.cart_items.inject(0) {|laters, i| laters += 1 if i.later == true}}
      end

      after(:all) do
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
        expect(basic_cart_now_items_count_initial).to be > 0
        expect(basic_cart_now_items_count_final).to eql(0)
      end

      it "increases the number of saved items by the number of previously-active items" do
        expect(basic_cart_later_items_count_final).to eql(basic_cart_later_items_count_initial + basic_cart_now_items_count_initial)
      end

      it "results in a cart in which all items are saved items" do
        expect(basic_cart_later_items_count_final).to eql(assigns(:cart).cart_items.count)
      end
    end

    context "when the cart already contains saved items" do
      render_views
      before(:all) do
        let!(:all_saved_cart) {create(:cart, :with_items_for_later)}
        let!(:all_saved_cart_id) { all_saved_cart.id }
        let!(:all_saved_cart_count) { all_saved_cart.cart_items.count }
        let!(:all_saved_cart_user) { all_saved_cart.user }
        let!(:all_saved_cart_now_items_count_initial) {all_saved_cart.cart_items.inject(0) {|nows, i| nows += 1 if i.later == false}}
        let!(:all_saved_cart_later_items_count_initial) {all_saved_cart.cart_items.inject(0) {|laters, i| laters += 1 if i.later == true}}

        sign_in(all_saved_cart_user)
        patch :save_all_items_for_later

        let!(:all_saved_cart_now_items_count_final) {basic_cart.cart_items.inject(0) {|nows, i| nows += 1 if i.later == false}}
        let!(:all_saved_cart_later_items_count_final) {basic_cart.cart_items.inject(0) {|laters, i| laters += 1 if i.later == true}}
      end

      after(:all) do
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
        expect(all_saved_cart_now_items_count_final).to eql(0)
      end

      it "results in a cart in which all items are saved items" do
        expect(basic_cart_later_items_count_final).to eql(assigns(:cart).cart_items.count)
      end
    end

    context "when the cart contains difficult-to-process items" do
      before(:all) do
        let!(:problem_cart) {create(:cart, :with_all_problematic_items)}
        let!(:problem_cart_id) { problem_cart.id }
        let!(:problem_cart_count) { problem_cart.cart_items.count }
        let!(:problem_cart_user) { problem_cart.user }
        let!(:problem_cart_now_items_count_initial) {problem_cart.cart_items.inject(0) {|nows, i| nows += 1 if i.later == false}}
        let!(:problem_cart_later_items_count_initial) {problem_cart.cart_items.inject(0) {|laters, i| laters += 1 if i.later == true}}

        sign_in(problem_cart_user)
        patch :save_all_items_for_later

        let!(:problem_cart_now_items_count_final) {problem_cart.cart_items.inject(0) {|nows, i| nows += 1 if i.later == false}}
        let!(:problem_cart_later_items_count_final) {problem_cart.cart_items.inject(0) {|laters, i| laters += 1 if i.later == true}}
      end

      after(:all) do
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
        expect(problem_cart_now_items_count_initial).to be > 0
        expect(problem_cart_now_items_count_final).to eql(0)
      end

      it "increases the number of saved items by the number of previously-active items" do
        expect(problem_cart_later_items_count_final).to eql(problem_cart_later_items_count_initial + problem_cart_now_items_count_initial)
      end

      it "results in a cart in which all items are saved items" do
        expect(problem_cart_later_items_count_final).to eql(assigns(:cart).cart_items.count)
      end
    end

    xcontext "when the cart contains 100 items" do
      before(:all) do
        let!(:century_cart) {create(:cart, :with_100_mixed)}
        let!(:century_cart_id) { century_cart.id }
        let!(:century_cart_count) { century_cart.cart_items.count }
        let!(:century_cart_user) { century_cart.user }
        let!(:century_cart_now_items_count_initial) {century_cart.cart_items.inject(0) {|nows, i| nows += 1 if i.later == false}}
        let!(:century_cart_later_items_count_initial) {century_cart.cart_items.inject(0) {|laters, i| laters += 1 if i.later == true}}

        sign_in(century_cart_user)
        patch :save_all_items_for_later

        let!(:century_cart_now_items_count_final) {century_cart.cart_items.inject(0) {|nows, i| nows += 1 if i.later == false}}
        let!(:century_cart_later_items_count_final) {century_cart.cart_items.inject(0) {|laters, i| laters += 1 if i.later == true}}
      end

      after(:all) do
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
        expect(century_cart_now_items_count_initial).to be > 0
        expect(century_cart_now_items_count_final).to eql(0)
      end

      it "increases the number of saved items by the number of previously-active items" do
        expect(century_cart_later_items_count_final).to eql(century_cart_later_items_count_initial + century_cart_now_items_count_initial)
      end

      it "results in a cart in which all items are saved items" do
        expect(century_cart_later_items_count_final).to eql(assigns(:cart).cart_items.count)
      end
    end
  end

  xdescribe "#move_all_saved_items_to_cart" do

    context "when the cart has items-for-later" do
    end

    context "when the cart has expired items" do
    end

    context "when the cart has unavailable items" do
    end

    context "when the cart contains items with an unknown kind" do
    end

    context "when the cart contains 100 items" do
    end

  end

  xdescribe "#verify_all_items_availability" do

    context "when the cart has items-for-later" do
    end

    context "when the cart has expired items" do
    end

    context "when the cart has unavailable items" do
    end

    context "when the cart contains items with an unknown kind" do
    end

    context "when the cart contains 100 items" do
    end

  end

  xdescribe "#remove_single_item" do

    context "when the item is basic" do
    end

    context "when the item is saved-for-later" do
    end

    context "when the item has an unknown kind" do
    end

    context "when the item is expired" do
    end

    context "when the item is marked unavailable" do
    end

    context "when the item is marked incomplete" do
    end

    context "when the items's item_name_memo doesn't match its acquirable's name" do
    end

    context "when the item's item_price_memo does't match it's acquirable's price_cents" do
    end

    context "when the cart contains 100 items" do
    end

  end

  xdescribe "PATCH verify_single_item_availability" do

  end

  xdescribe "#save_item_for_later" do

    context "when the item is basic" do
    end

    context "when the item is saved-for-later" do
    end

    context "when the item has an unknown kind" do
    end

    context "when the item is expired" do
    end

    context "when the item is marked unavailable" do
    end

    context "when the items's item_name_memo doesn't match its acquirable's name" do
    end

    context "when the item's item_price_memo does't match it's acquirable's price_cents" do
    end

    context "when the cart contains 100 items" do
    end

  end


  describe "#move_item_to_cart" do

    context "when the item is basic" do
    end

    context "when the item is saved-for-later" do
    end

    context "when the item has an unknown kind" do
    end

    context "when the item is expired" do
    end

    context "when the item is marked unavailable" do
    end

    context "when the items's item_name_memo doesn't match its acquirable's name" do
    end

    context "when the item's item_price_memo does't match it's acquirable's price_cents" do
    end

    context "when the cart has items-for-later" do
    end

    context "when the cart has expired items" do
    end

    context "when the cart has unavailable items" do
    end

    context "when the cart contains items with an unknown kind" do
    end

    context "when the cart contains 100 items" do
    end

  end

  xdescribe "#edit_single_item" do
  end

  xdescribe "#update" do
  end
end
