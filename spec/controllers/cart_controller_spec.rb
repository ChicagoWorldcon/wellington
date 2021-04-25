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
  render_views

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
  let(:naive_user) { create(:user)}

  let(:existing_cart_chassis) {create(:cart_chassis, :with_basic_items_cart_for_now, :with_basic_items_cart_for_later)}
  let(:existing_user) {existing_cart_chassis.user}

  let(:empty_cart_chassis) { create(:cart_chassis)}
  let(:empty_user) { empty_cart_chassis.user }

  let(:paid_reservations_chassis) { create(:cart_chassis, :with_paid_reservations_cart_for_now, :with_paid_reservations_cart_for_later)}
  let(:paid_reservations_user) { paid_reservations_chassis.user }


  let(:adult_memb) { create(:membership, :adult) }
  let(:valid_a_memb_offer) { MembershipOffer.new(adult_memb) }

  let(:child_memb) { create(:membership, :child) }
  let(:valid_child_memb_offer) { MembershipOffer.new(child_memb) }

  describe "GET #show" do
    context "when a first-time user is signed in" do
      before do
        sign_in(naive_user)
        get :show
      end

      it "creates a cart for the new user" do
        expect(assigns(:cart_chassis)).to be_a(CartChassis) #rg-checked

        # Why yes, as a matter of fact, this IS the worst sin
        # against controller-testing best practices ever!
        # When I get to writing request specs, this will be removed.
        expect(assigns(:cart_chassis).user).to eql(naive_user) #rg-checked
        expect(assigns(:cart_chassis).all_items_count).to eql(0) #rg-checked
      end

      it "renders" do
        expect(response).to have_http_status(:ok) #rg-checked
        expect(subject).to render_template(:cart) #rg-checked
      end
    end

    context "when a user with an existing cart is signed in" do

      before do
        sign_in(existing_user)
        get :show
      end

      it "finds the user's existing carts" do
        expect(assigns(:cart_chassis).user).to eql(existing_user) #rg-checked
        expect(assigns(:cart_chassis).now_bin.id).to eql(existing_cart_chassis.now_bin.id) #rg-checked
        expect(assigns(:cart_chassis).later_bin.id).to eql(existing_cart_chassis.later_bin.id) #rg-checked
        expect(assigns(:cart_chassis).all_items_count).to be > 0 #rg-checked
        expect(assigns(:cart_chassis).all_items_count).to eql(existing_cart_chassis.all_items_count) #rg-checked
      end

      it "renders" do
        expect(response).to have_http_status(:ok) #rg-checked
      end
    end

    context "when a support user is signed in" do

      before do
        sign_in(support_user)
        get :show
      end

      it "redirects to the root path" do
        expect(response).to have_http_status(:found) #rg-checked
        expect(response).to redirect_to(root_path) #rg-checked
      end

      it "sets a flash message about logging into your personal account to make personal purchases"  do
        expect(subject).to set_flash[:alert].to(/personal/) #rg-checked
      end
    end

    context "without sign-in" do
      before do
        get :show
      end

      it "redirects to the root path" do
        expect(response).to have_http_status(:found) #rg-checked
        expect(response).to redirect_to(root_path) #rg-checked
      end
    end
  end

  describe "POST #add_reservation_to_cart" do
    before do
      @initial_existing_chassis_full_item_count = existing_cart_chassis.all_items_count
      @initial_existing_chassis_now_bin_count = existing_cart_chassis.now_items_count
    end

    context "when the membembership is active and the beneficiary has all the necessary info" do

      before do
        sign_in(existing_user)

        post :add_reservation_to_cart, params: {
          contact_model_key => valid_contact_params_with_dob,
          :offer => valid_a_memb_offer.hash
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "locates the user's cart" do
        expect(assigns(:cart_chassis)).to be_a(CartChassis) #rg-checked
        expect(assigns(:cart_chassis).now_bin).to eq(existing_cart_chassis.now_bin) #rg-checked
        expect(assigns(:cart_chassis).user).to eq(existing_cart_chassis.user) #rg-checked
      end

      # it "creates an offer object per our params" do
      #   expect(assigns(:our_offer)).to be_a(MembershipOffer)
      #   expect(assigns(:our_offer).hash).to eq(valid_a_memb_offer.hash)
      # end

      # it "creates a contact object" do
      #   expect(assigns(:our_beneficiary)).to be_a(Claim.contact_strategy)
      #   expect(assigns(:our_beneficiary).first_name).to eq(valid_contact_params_with_dob[:first_name])
      # end

      # it "populates the contact object's date_of_birth field with a date object" do
      #   expect(assigns(:our_beneficiary).date_of_birth).to be_a(Date)
      # end

      # it "creates a cart item per our params" do
      #   expect(assigns(:our_cart_item)).to be_a(CartItem)
      #   expect(assigns(:our_cart_item).acquirable.name).to eq(offer_valid.membership.name)
      #   expect(assigns(:our_cart_item).benefitable.last_name).to eq(valid_contact_params_with_dob[:last_name])
      # end

      it "adds a new CartItem reflecting our offer to the now_bin of the cart_chassis" do
        expect(assigns(:cart_chassis).all_items_count).to eql(@initial_existing_chassis_full_item_count + 1) #rg-checked
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_existing_chassis_now_bin_count + 1) #rg-checked
        expect(assigns(:cart_chassis).now_items.last.acquirable.display_name).to eql(adult_memb.display_name) #rg-checked
      end

      it "sets a flash message about successfully adding the item"  do
        expect(subject).to set_flash[:notice].to(/successfully added/) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end
    end

    context "when there are issues with the beneficiary or the membership" do
      context "when the HTTP_REFERER has been set" do

        before do
          sign_in(existing_user)
        end

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
            expect(response).to have_http_status(:found) #rg-checked
            expect(response).to redirect_to(memberships_path) #rg-checked
          end

          it "sets a flash error about the membership no longer being available" do
            expect(subject).to set_flash[:alert].to(/unavailable/i) #rg-checked
          end

          it "does not add a new item to the cart" do
            expect(assigns(:cart_chassis).all_items_count).to eql(@initial_existing_chassis_full_item_count) #rg-checked
          end
        end
      end

      context "when the HTTP_REFERER has not been set" do

        before do
          sign_in(existing_user)
        end

        before(:each) do
          request.env['HTTP_REFERER'] = nil
        end

        context "when the beneficiary is invalid" do
          # let(:adult) { create(:membership, :adult) }
          # let(:offer_valid) { MembershipOffer.new(adult) }
          # let(:starting_good_enough_cart_count) {good_enough_cart.cart_items.count}

          before do
            post :add_reservation_to_cart, params: {
              contact_model_key => invalid_contact_params,
              :offer => valid_a_memb_offer.hash
            }
          end

          it "redirects to the fallback path" do
            expect(response).to have_http_status(:found) #rg-checked
            expect(response).to redirect_to(root_path) #rg-checked
          end

          it "sets a flash error" do
            expect(subject).to set_flash[:alert].to(/address/i) #rg-checked
          end

          it "does not add the item to the cart" do
            expect(assigns(:cart_chassis).all_items_count).to eql(@initial_existing_chassis_full_item_count) #rg-checked
          end
        end
      end

      context "when the beneficiary params do not include a date of birth" do
        context "when the date-of-birth is not required by the membership" do

          before do
            sign_in(existing_user)

            post :add_reservation_to_cart, params: {
              contact_model_key => valid_contact_params,
              :offer => valid_a_memb_offer.hash
            }
          end

          after do
            sign_out(existing_user)
          end

          it "adds the item to the cart" do
            expect(assigns(:cart_chassis).now_items_count).to eql(@initial_existing_chassis_now_bin_count + 1) #rg-checked
          end

          it "creates a benefitable, but leaves the contact object's date_of_birth field empty" do
            our_new_item = assigns(:cart_chassis).now_items.last
            expect(our_new_item.benefitable.present?).to eql(true)
            expect(our_new_item.benefitable.date_of_birth).to be_nil
          end
        end

        context "when the membership DOES requires a date of birth" do

          before do
            sign_in(existing_user)

            post :add_reservation_to_cart, params: {
              contact_model_key => valid_contact_params,
              :offer => valid_child_memb_offer.hash
            }
          end

          after do
            sign_out(existing_user)
          end

          it "adds the item to the cart" do
            expect(assigns(:cart_chassis).now_items_count).to eql(@initial_existing_chassis_now_bin_count + 1) #rg-checked
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do

    context "when the cart is empty" do

      before do
        @empty_cart_chassis_item_count = empty_cart_chassis.all_items_count
        @empty_c_c_now_id = empty_cart_chassis.now_bin.id
        @empty_c_c_later_id = empty_cart_chassis.later_bin.id
      end

      before do
        sign_in(empty_user)
        delete :destroy
      end

      after do
        sign_out(empty_user)
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not destroy the CartChassis object, or either of its bins" do
        expect(assigns(:cart_chassis)).not_to be_nil #rg-checked

        expect(assigns(:cart_chassis).now_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin.id).to eql(@empty_c_c_now_id) #rg-checked

        expect(assigns(:cart_chassis).later_bin).not_to be_nil
        expect(assigns(:cart_chassis).later_bin.id).to eql(@empty_c_c_later_id) #rg-checked
      end


      it "ends with the cart completely empty" do
        #Validation of the test:
        expect(assigns(:cart_chassis).all_items_count).to eql(@empty_cart_chassis_item_count) #rg-checked

        #actual test:
        expect(assigns(:cart_chassis).all_items_count).to eql(0) #rg-checked
      end
    end

    context "when both of the cart's bins contain items" do

      before do
        @existing_c_c_now_item_count = existing_cart_chassis.now_items_count
        @existing_c_c_now_id = existing_cart_chassis.now_bin.id
        @existing_c_c_later_item_count = existing_cart_chassis.later_items_count
        @existing_c_c_later_id = existing_cart_chassis.later_bin.id
      end

      before do
        sign_in(existing_user)
        delete :destroy
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not destroy the CartChassis object, or either of its bins" do
        expect(assigns(:cart_chassis)).not_to be_nil #rg-checked

        expect(assigns(:cart_chassis).now_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin.id).to eql(@existing_c_c_now_id) #rg-checked

        expect(assigns(:cart_chassis).later_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).later_bin.id).to eql(@existing_c_c_later_id) #rg-checked
      end

      it "completely clears out the cart" do
        #Validation of the test
        expect(@existing_c_c_now_item_count).to be > 0 #rg-checked
        expect(@existing_c_c_later_item_count).to be > 0 #rg-checked
        #Actual test
        expect(assigns(:cart_chassis).now_items_count).to eql(0) #rg-checked
        expect(assigns(:cart_chassis).later_items_count).to eql(0) #rg-checked
      end
    end
  end

  describe "DELETE #destroy_active" do

    context "when the cart is empty" do

      before do
        @empty_cart_chassis_item_count = empty_cart_chassis.all_items_count
        @empty_cart_chassis_now_id = empty_cart_chassis.now_bin.id
        @empty_cart_chassis_later_id = empty_cart_chassis.later_bin.id

        sign_in(empty_user)
        delete :destroy_active
      end

      it "succeeds" do
        expect(response).to have_http_status(:found)  #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not destroy the CartChassis object, or either of the bins" do
        expect(assigns(:cart_chassis)).not_to be_nil  #rg-checked

        expect(assigns(:cart_chassis).now_bin).not_to be_nil  #rg-checked
        expect(assigns(:cart_chassis).now_bin.id).to eql(@empty_cart_chassis_now_id)  #rg-checked

        expect(assigns(:cart_chassis).later_bin).not_to be_nil  #rg-checked
        expect(assigns(:cart_chassis).later_bin.id).to eql(@empty_cart_chassis_later_id)  #rg-checked
      end

      it "ends with the CartChassis's now_bin completely empty" do
        expect(assigns(:cart_chassis).now_items_count).to eql(0)  #rg-checked
      end

      it "does not change the overall number of items in the cart" do
        #Validation of the test:
        expect(assigns(:cart_chassis).all_items_count).to eql(@empty_cart_chassis_item_count)  #rg-checked
      end
    end

    context "when the cart has items in both bins" do
      before do
        @existing_c_c_now_item_count = existing_cart_chassis.now_items_count
        @existing_c_c_now_id = existing_cart_chassis.now_bin.id
        @existing_c_c_later_item_count = existing_cart_chassis.later_items_count
        @existing_c_c_later_id = existing_cart_chassis.later_bin.id

        sign_in(existing_user)
        delete :destroy_active
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "Does not destroy the Cart object, or either of the bins" do
        expect(assigns(:cart_chassis)).not_to be_nil #rg-checked

        expect(assigns(:cart_chassis).now_bin).not_to be_nil  #rg-checked
        expect(assigns(:cart_chassis).now_bin.id).to eql(@existing_c_c_now_id)  #rg-checked

        expect(assigns(:cart_chassis).later_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).later_bin.id).to eql(@existing_c_c_later_id) #rg-checked
      end

      it "clears the items from the now_bin" do
        expect(@existing_c_c_now_item_count).to be > 0 #rg-checked
        expect(assigns(:cart_chassis).now_items_count).to eql(0) #rg-checked
      end

      it "does not change the number of items in the later_bin " do
        expect(@existing_c_c_later_item_count).to be > 0 #rg-checked
        expect(assigns(:cart_chassis).later_items_count).to eql(@existing_c_c_later_item_count) #rg-checked
      end
    end
  end

  describe "DELETE #destroy_saved" do

    context "when the cart is empty" do

      before do
        @empty_cart_chassis_item_count = empty_cart_chassis.all_items_count
        @empty_cart_chassis_now_id = empty_cart_chassis.now_bin.id
        @empty_cart_chassis_later_id = empty_cart_chassis.later_bin.id

        sign_in(empty_user)
        delete :destroy_saved
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not destroy the CartChassis object, or either of its bins" do
        expect(assigns(:cart_chassis)).not_to be_nil #rg-checked

        expect(assigns(:cart_chassis).now_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin.id).to eql(@empty_cart_chassis_now_id) #rg-checked

        expect(assigns(:cart_chassis).later_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).later_bin.id).to eql(@empty_cart_chassis_later_id) #rg-checked
      end

      it "ends with the cart completely empty" do
        #Validation of the test:
        expect(@empty_cart_chassis_item_count).to eql(0) #rg-checked

        #actual test:
        expect(assigns(:cart_chassis).all_items_count).to eql(0) #rg-checked
      end
    end

    context "when the cart has items in both bins" do
      before do
        @existing_c_c_now_bin_id = existing_cart_chassis.now_bin.id
        @existing_c_c_now_items_count = existing_cart_chassis.now_items_count
        @existing_c_c_later_bin_id = existing_cart_chassis.later_bin.id
        @existing_c_c_later_items_count = existing_cart_chassis.later_items_count

        sign_in(existing_user)
        delete :destroy_saved
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "Does not destroy the Cart object" do
        expect(assigns(:cart_chassis)).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin.id).to eql(@existing_c_c_now_bin_id) #rg-checked
        expect(assigns(:cart_chassis).later_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).later_bin.id).to eql(@existing_c_c_later_bin_id) #rg-checked
      end

      it "clears all the items from the CartChassis's later_bin" do
        expect(@existing_c_c_later_items_count).to be > 0 #rg-checked
        expect(assigns(:cart_chassis).later_items_count).to eql(0) #rg-checked
      end

      it "does not affect the number of items in the CartChassis's now_bin" do
        expect(@existing_c_c_now_items_count).to be > 0 #rg-checked
        expect(assigns(:cart_chassis).now_items_count).to eql(@existing_c_c_now_items_count) #rg-checked
      end
    end
  end

  describe "DELETE #remove_single_item" do
    context "when the item comes from the CartChassis's now_bin" do

      before do
        @initial_all_items_count = existing_cart_chassis.all_items_count
        @initial_now_count = existing_cart_chassis.now_items_count
        @our_item = existing_cart_chassis.now_items.sample
        @our_item_id = @our_item.id

        sign_in(existing_user)

        delete :remove_single_item, params: {
          :id => @our_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found)
      end

      it "sets a flash notice about succeeding" do
        expect(subject).to set_flash[:notice].to(/successfully/i)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
      end

      it "destroys the cart_item in question" do
        expect { @our_item.reload }.to raise_error #rg-checked
      end

      it "reduces the number of items in the now_bin by one" do
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_now_count - 1) #rg-checked
        expect(assigns(:cart_chassis).all_items_count).to eql(@initial_all_items_count - 1) #rg-checked
      end
    end

    context "when the item is in the CartChassis's later_bin" do
      before do
        @initial_all_items_count = existing_cart_chassis.all_items_count
        @initial_later_count = existing_cart_chassis.later_items_count
        @our_item = existing_cart_chassis.later_items.sample
        @our_item_id = @our_item.id

        sign_in(existing_user)

        delete :remove_single_item, params: {
          :id => @our_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash notice about succeeding" do
        expect(subject).to set_flash[:notice].to(/successfully/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "destroys the cart_item in question" do
        expect { @our_item.reload }.to raise_error #rg-checked
      end

      it "reduces the number of items in the later_bin by one" do
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_later_count - 1) #rg-checked
        expect(assigns(:cart_chassis).all_items_count).to eql(@initial_all_items_count - 1) #rg-checked
      end
    end

    context "when the item is associated with a paid reservation" do

      before do
        @initial_all_items_count = paid_reservations_chassis.all_items_count
        @initial_later_count = paid_reservations_chassis.later_items_count
        @initial_now_count = paid_reservations_chassis.now_items_count
        @our_item = paid_reservations_chassis.now_items.sample
        @our_item_id = @our_item.id
        @our_item_reservation = @our_item.holdable

        sign_in(paid_reservations_user)
        delete :remove_single_item, params: {
          :id => @our_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash notice about succeeding" do
        expect(subject).to set_flash[:notice].to(/successfully/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "destroys the cart_item in question" do
        expect { @our_item.reload }.to raise_error #rg-checked
      end

      it "removes the targeted item from the cart" do
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_later_count - 1) #rg-checked
        expect(assigns(:cart_chassis).all_items_count).to eql(@initial_all_items_count - 1) #rg-checked
      end

      it "does not destroy the associated reservation" do
        @our_item_reservation.reload
        expect(@our_item_reservation).not_to be_nil #rg-checked
      end
    end

    context "when the items is invalid" do

      before do
        @initial_all_items_count = existing_cart_chassis.all_items_count
        @initial_now_count = existing_cart_chassis.now_items_count
        @our_item = existing_cart_chassis.now_items.sample
        @our_item.update_attribute(:item_price_memo, "ten")
        @our_item_id = @our_item.id

        sign_in(existing_user)

        delete :remove_single_item, params: {
          :id => @our_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash notice about succeeding" do
        expect(subject).to set_flash[:notice].to(/successfully/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "destroys the cart_item in question" do
        expect { @our_item.reload }.to raise_error #rg-checked
      end

      it "removes the targeted item from the cart" do
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_now_count - 1) #rg-checked
        expect(assigns(:cart_chassis).all_items_count).to eql(@initial_all_items_count - 1) #rg-checked
      end
    end

    context "when the item is not in the user's cart" do
      let(:nowhere_cart_chassis) {create(:cart_chassis, :with_basic_items_cart_for_now)}

      before do
        @nowhere_item = nowhere_cart_chassis.now_items.sample
        @nowhere_id = @nowhere_item.id
        @nowhere_bin = @nowhere_item.cart

        @existing_chassis_overall_count = existing_cart_chassis.all_items_count

        sign_in(existing_user)

        delete :remove_single_item, params: {
          :id => @nowhere_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash notice about not recognizing the item" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "Does not reduce the number of items in the cart" do
        expect(assigns(:cart_chassis).all_items_count).to eql(@existing_chassis_overall_count) #rg-checked
      end

      it "Does not destroy the cart_item" do
        expect { @nowhere_item.reload }.not_to raise_error #rg-checked
      end

      it "Does not change the item's original cart association" do
        expect(@nowhere_item.cart).not_to eql(assigns(:cart_chassis).now_bin.id) #rg-checked
        expect(@nowhere_item.cart).not_to eql(assigns(:cart_chassis).later_bin.id) #rg-checked
        expect(@nowhere_item.cart).to eql(@nowhere_bin) #rg-checked
      end
    end

    context "when the item has already been removed" do
      # let(:meh_cart) { create(:cart, :with_basic_items) }
      # let(:meh_cart_id) { meh_cart.id }
      # let(:meh_cart_user) { meh_cart.user }
      # let(:doomed_item) {meh_cart.cart_items.sample}
      # let(:doomed_item_id) {doomed_item.id}
      # let(:total_cart_items) {CartItem.count}
      # let(:meh_cart_count) { meh_cart.cart_items.count }

      before do
        @initial_now_count = existing_cart_chassis.now_items_count
        @doomed_item = existing_cart_chassis.now_items.sample
        @doomed_item_id = @doomed_item.id

        @doomed_item.destroy
        existing_cart_chassis.full_reload
        @intermediate_now_count = existing_cart_chassis.now_items_count
        @total_cart_items = CartItem.count

        sign_in(existing_user)
        delete :remove_single_item, params: {
          :id => @doomed_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash notice about not recognizing the item" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "Does not reduce the number of items in the cart" do
        expect(assigns(:cart_chassis).now_items_count).to eql(@intermediate_now_count) #rg-checked
      end

      it "Does not reduce the number of CartItems in the database" do
        expect(@total_cart_items).to eql(CartItem.count) #rg-checked
      end
    end
  end

  describe "PATCH #save_item_for_later" do

    context "when the item is in the CartChassis's now_bin" do

      before do
        @our_item = existing_cart_chassis.now_items.sample
        @our_item_id = @our_item.id
        @initial_now_count = existing_cart_chassis.now_items_count
        @initial_later_count = existing_cart_chassis.later_items_count

        sign_in(existing_user)
        patch :save_item_for_later, params: {
          :id => @our_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash notice about being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i) #inverted
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "reduces the number if items in the CartChassis's now_bin by one" do
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_now_count - 1) #rg-checked
      end

      it "increases the number if items in the CartChassis's later_bin by one" do
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_later_count + 1) #rg-checked
      end
    end

    context "when the item is in the CartChassis's later_bin" do

      before do
        @our_item = existing_cart_chassis.later_items.sample
        @our_item_id = @our_item.id
        @initial_now_count = existing_cart_chassis.now_items_count
        @initial_later_count = existing_cart_chassis.later_items_count

        sign_in(existing_user)
        patch :save_item_for_later, params: {
          :id => @our_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash notice about being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not change the number of items in CartChassis's now_bin" do
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_now_count) #rg-checked
      end

      it "does not change the number of items in CartChassis's later_bin" do
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_later_count) #rg-checked
      end
    end


    context "when the item is expired" do
      let(:expired_item) { create(:cart_item, :with_expired_membership) }

      before do
        expired_item.update_attribute(:cart, existing_cart_chassis.now_bin)
        existing_cart_chassis.full_reload
        @expired_item_id = expired_item.id
        @initial_now_count = existing_cart_chassis.now_items_count
        @initial_later_count = existing_cart_chassis.later_items_count

        sign_in(existing_user)
        patch :save_item_for_later, params: {
          :id => @expired_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash notice about being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "reduces the number of items in the CartChassis's now_bin by one" do
        # Test validation:
        expect(@initial_now_count).to be > @initial_later_count #rg-checked
        # Actual test:
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_now_count - 1) #rg-checked
      end

      it "increases the number of items in the CartChassis's later_bin by one" do
        # Test validation:
        expect(@initial_later_count).to be < @initial_now_count #rg-checked
        # Actual test:
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_later_count + 1) #rg-checked
      end
    end

    context "when the item is not in the user's cart" do
      let(:rando_item) { create(:cart_item) }

      before do
        @extraneous_item_id = rando_item.id
        @extraneous_item_bin = rando_item.cart
        @initial_now_count = existing_cart_chassis.now_items_count
        @initial_later_count = existing_cart_chassis.later_items_count

        sign_in(existing_user)
        patch :save_item_for_later, params: {
          :id => @extraneous_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not affect the number of items in the now_bin or the later_bin" do
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_now_count) #rg-checked
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_later_count) #rg-checked
      end
    end

    context "when the item no longer exists" do

      before do
        @doomed_item = existing_cart_chassis.now_items.sample
        @doomed_item_id = @doomed_item.id

        @doomed_item.destroy
        existing_cart_chassis.full_reload

        @initial_now_count = existing_cart_chassis.now_items_count
        @initial_later_count = existing_cart_chassis.later_items_count

        sign_in(existing_user)
        patch :save_item_for_later, params: {
          :id => @doomed_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not affect the number of items in the now_bin or the later_bin" do
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_now_count) #rg-checked
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_later_count)  #rg-checked
      end
    end
  end

  describe "PATCH #move_item_to_cart" do
    context "when the item is in the CartChassis's later_bin" do
      before do
        @our_item = existing_cart_chassis.later_items.sample
        @our_item_id = @our_item.id
        @initial_now_count = existing_cart_chassis.now_items_count
        @initial_later_count = existing_cart_chassis.later_items_count

        sign_in(existing_user)
        patch :move_item_to_cart, params: {
          :id => @our_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash notice about being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "increases the number of items in the CartChassis's now_bin by one" do
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_now_count + 1) #rg-checked
      end

      it "decreases the number of items in the CartChassis's later_bin by one" do
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_later_count - 1) #rg-checked
      end
    end

    context "when the item is in the CartChassis's now_bin" do
      before do
        @our_item = existing_cart_chassis.now_items.sample
        @our_item_id = @our_item.id
        @initial_now_count = existing_cart_chassis.now_items_count
        @initial_later_count = existing_cart_chassis.later_items_count

        sign_in(existing_user)
        patch :move_item_to_cart, params: {
          :id => @our_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash notice about being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not change the number of items in the CartChassis's now_bin" do
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_now_count) #rg-checked
      end

      it "does not change the number of items in the CartChassis's later_bin by one" do
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_later_count) #rg-checked
      end
    end


    context "when the item is expired" do
      let(:expired_item) { create(:cart_item, :with_expired_membership) }

      before do
        expired_item.update_attribute(:cart, existing_cart_chassis.later_bin)
        existing_cart_chassis.full_reload
        @expired_item_id = expired_item.id
        @initial_now_count = existing_cart_chassis.now_items_count
        @initial_later_count = existing_cart_chassis.later_items_count

        sign_in(existing_user)
        patch :move_item_to_cart, params: {
          :id => @expired_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash notice about being successful" do
        expect(subject).to set_flash[:notice].to(/successful/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "increases the number of items in the CartChassis's now_bin by one" do
        # Test validation:
        expect(@initial_now_count).to be < @initial_later_count #rg-checked
        # Actual test:
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_now_count + 1) #rg-checked
      end

      it "reduces the number of items in the CartChassis's later_bin by one" do
        # Test validation:
        expect(@initial_later_count).to be > @initial_now_count #rg-checked
        # Actual test:
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_later_count - 1) #rg-checked
      end
    end

    context "when the item is not in the user's cart" do
      let(:rando_item) { create(:cart_item) }

      before do
        @extraneous_item_id = rando_item.id
        @extraneous_item_bin = rando_item.cart
        @initial_now_count = existing_cart_chassis.now_items_count
        @initial_later_count = existing_cart_chassis.later_items_count

        sign_in(existing_user)
        patch :move_item_to_cart, params: {
          :id => @extraneous_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not affect the number of items in the now_bin or the later_bin" do
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_now_count) #rg-checked
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_later_count) #rg-checked
      end
    end

    context "when the item no longer exists" do

      before do
        @doomed_item = existing_cart_chassis.now_items.sample
        @doomed_item_id = @doomed_item.id

        @doomed_item.destroy
        existing_cart_chassis.full_reload

        @initial_now_count = existing_cart_chassis.now_items_count
        @initial_later_count = existing_cart_chassis.later_items_count

        sign_in(existing_user)
        patch :save_item_for_later, params: {
          :id => @doomed_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not affect the number of items in the now_bin or the later_bin" do
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_now_count) #rg-checked
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_later_count)  #rg-checked
      end
    end
  end

#
#
#
#
#  STOPPING POINT
#
#
#


  xdescribe "PATCH #save_all_items_for_later" do
    context "when the cart is empty" do
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
        expect(response).to have_http_status(:found)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
        expect(response).to have_http_status(:found)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
        expect(response).to have_http_status(:found)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
        expect(response).to have_http_status(:found)
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
      render_views false

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
        expect(response).to have_http_status(:found)
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

  xdescribe "PATCH #move_all_saved_items_to_cart" do
    context "when the cart is empty" do

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
        expect(response).to have_http_status(:found)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
        expect(response).to have_http_status(:found)
        expect(subject).to set_flash[:notice].to(/successfully/)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
      render_views false

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
        expect(response).to have_http_status(:found)
        expect(subject).to set_flash[:notice].to(/successfully moved/i)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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

  xdescribe "PATCH #verify_single_item_availability" do

    context "when the item is basic" do

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
        expect(response).to have_http_status(:found)
      end

      it "sets a flash notice about the item being available" do
        expect(subject).to set_flash[:notice].to(/good news/i)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
        expect(response).to have_http_status(:found)
      end

      it "sets a positive flash notice" do
        expect(subject).to set_flash[:notice].to(/good news/i)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
        expect(response).to have_http_status(:found)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
        expect(response).to have_http_status(:found)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
        expect(response).to have_http_status(:found)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
        expect(response).to have_http_status(:found)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
        expect(response).to have_http_status(:found)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
        expect(response).to have_http_status(:found)
      end

      it "sets a flash alert" do
        pending
        expect(subject).to set_flash[:alert].to(/no longer/i)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
      end

      it "ends with the target item having its 'available' attribute changed to false" do
        pending
        expect(incom_item_available).to eql(true)
        expect(assigns(:target_item).available).to eql(false)
      end
    end
  end


  xdescribe "PATCH #verify_all_items_availability" do

    context "when the cart contains only basic items" do

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
        expect(response).to have_http_status(:found)
        expect(subject).not_to set_flash[:alert]
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
        expect(response).to have_http_status(:found)
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
        expect(response).to have_http_status(:found)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert]
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
        expect(response).to have_http_status(:found)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert]
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
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
      render_views false

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
        expect(response).to have_http_status(:found)
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert]
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)
      end

      it "does not change the total number of CartItems in the cart" do
        expect(hundo_cart_count).to eql(assigns(:cart).cart_items.count)
      end
    end
  end

  xdescribe "GET #preview_online_purchase" do
    pending
  end


  xdescribe "POST #submit_online_payment" do
    pending
  end

  xdescribe "POST #pay_with_cheque" do
    pending
  end
end
