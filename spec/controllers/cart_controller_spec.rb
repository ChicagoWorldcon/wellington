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

  let(:empty_cart_chassis) { create(:cart_chassis)}
  let(:empty_user) { empty_cart_chassis.user }

  let(:existing_cart_chassis) {create(:cart_chassis, :with_basic_items_cart_for_now, :with_basic_items_cart_for_later)}
  let(:existing_user) {existing_cart_chassis.user}

  let(:now_only_cart_chassis) {create(:cart_chassis, :with_basic_items_cart_for_now)}
  let(:now_only_user) {now_only_cart_chassis.user}

  let(:saved_only_cart_chassis) {create(:cart_chassis, :with_basic_items_cart_for_later)}
  let(:saved_only_user) {saved_only_cart_chassis.user}

  let(:paid_reservations_chassis) { create(:cart_chassis, :with_paid_reservations_cart_for_now, :with_paid_reservations_cart_for_later)}
  let(:paid_reservations_user) { paid_reservations_chassis.user }

  let(:part_paid_res_chassis) { create(:cart_chassis, :with_partially_paid_reservations_cart_for_now, :with_partially_paid_reservations_cart_for_later)}
  let(:part_paid_res_user) {part_paid_res_chassis.user}

  let(:adult_memb) { create(:membership, :adult) }
  let(:valid_a_memb_offer) { MembershipOffer.new(adult_memb) }

  let(:child_memb) { create(:membership, :child) }
  let(:valid_child_memb_offer) { MembershipOffer.new(child_memb) }

  let(:whatevs_item) { create(:cart_item) }
  let(:expired_item) { create(:cart_item, :with_expired_membership) }
  let(:price_altered_item) { create(:cart_item, :price_altered) }
  let(:name_altered_item) { create(:cart_item, :name_altered) }
  let(:unavailable_item) { create(:cart_item, :unavailable) }
  let(:unknown_kind_item) { create(:cart_item, :unknown_kind) }
  let(:unpaid_res_item) { create(:cart_item, :with_unpaid_reservation) }
  let(:part_paid_res_item) { create(:cart_item, :with_partially_paid_reservation) }
  let(:paid_res_item) { create(:cart_item, :with_paid_reservation) }
  let(:free_item) { create(:cart_item, :with_free_membership) }

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

  describe "PATCH #save_all_items_for_later" do
    context "when the cart is empty" do

      before do
        @now_bin_id = empty_cart_chassis.now_bin.id
        @later_bin_id = empty_cart_chassis.later_bin.id
        @initial_item_count = empty_cart_chassis.all_items_count

        sign_in(empty_user)
        patch :save_all_items_for_later
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not destroy the CartChassis object, or either of the bins" do
        expect(assigns(:cart_chassis)).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin.id).to eql(@now_bin_id) #rg-checked
        expect(assigns(:cart_chassis).later_bin.id).to eql(@later_bin_id) #rg-checked
      end

      it "ends with the cart completely empty" do
        #Validation of the test:
        expect(assigns(:cart_chassis).all_items_count).to eql(@initial_item_count) #rg-checked

        #actual test:
        expect(assigns(:cart_chassis).all_items_count).to eql(0) #rg-checked
      end
    end

    context "when the cart has only basic items" do

      before do
        @now_bin_id = existing_cart_chassis.now_bin.id
        @later_bin_id = existing_cart_chassis.later_bin.id
        @initial_now_count = existing_cart_chassis.now_items_count
        @initial_later_count = existing_cart_chassis.later_items_count

        sign_in(existing_user)
        patch :save_all_items_for_later
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not destroy the CartChassis object, or either of the bins" do
        expect(assigns(:cart_chassis)).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin.id).to eql(@now_bin_id) #rg-checked
        expect(assigns(:cart_chassis).later_bin.id).to eql(@later_bin_id) #rg-checked
      end

      it "does not change the total number of CartItems in the cart" do
        expect(assigns(:cart_chassis).all_items_count).to eql(@initial_now_count + @initial_later_count) #rg-checked
      end

      it "reduces the number of unsaved items in the cart to zero" do
        expect(@initial_now_count).to be > 0 #rg-checked
        expect(assigns(:cart_chassis).now_items_count).to eql(0) #rg-checked
      end

      it "increases the number of saved items by the number of previously-active items" do
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_later_count + @initial_now_count) #rg-checked
      end

      it "results in a cart in which all items are saved items" do
        expect(assigns(:cart_chassis).all_items_count).to be > 0 #rg-checked
        expect(assigns(:cart_chassis).now_items_count).to eql(0) #rg-checked
      end
    end

    context "when the cart contains only saved items" do

      before do
        @now_bin_id = saved_only_cart_chassis.now_bin.id
        @later_bin_id = saved_only_cart_chassis.later_bin.id
        @initial_now_count = saved_only_cart_chassis.now_items_count
        @initial_later_count = saved_only_cart_chassis.later_items_count
        @initial_all_items_count = saved_only_cart_chassis.all_items_count

        sign_in(saved_only_user)
        patch :save_all_items_for_later
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not destroy the CartChassis object, or either of the bins" do
        expect(assigns(:cart_chassis)).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin.id).to eql(@now_bin_id) #rg-checked
        expect(assigns(:cart_chassis).later_bin.id).to eql(@later_bin_id) #rg-checked
      end

      it "does not change the total number of CartItems in the cart" do
        expect(assigns(:cart_chassis).all_items_count).to eql(@initial_all_items_count) #rg-checked
      end

      it "results in a cart in which there are no items that are not saved for later" do
        expect(assigns(:cart_chassis).now_items_count).to eql(0) #rg-checked
      end

      it "results in no change in the initial numbers of items-for-later and items-for-now" do
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_now_count) #rg-checked
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_later_count) #rg-checked
      end
    end

    context "when the cart's now_bin contains an invalid item" do
      before do
        whatevs_item.update_attribute(:item_price_memo, "some price")
        whatevs_item.update_attribute(:cart, existing_cart_chassis.now_bin)

        @now_bin_id = existing_cart_chassis.now_bin.id
        @later_bin_id = existing_cart_chassis.later_bin.id
        @initial_now_count = existing_cart_chassis.now_items_count
        @initial_later_count = existing_cart_chassis.later_items_count
        @initial_all_items_count = existing_cart_chassis.all_items_count

        sign_in(existing_user)
        patch :save_all_items_for_later
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "does not destroy the CartChassis object, or either of the bins" do
        expect(assigns(:cart_chassis)).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin.id).to eql(@now_bin_id) #rg-checked
        expect(assigns(:cart_chassis).later_bin.id).to eql(@later_bin_id) #rg-checked
      end

      it "does not change the total number of CartItems in the cart" do
        expect(assigns(:cart_chassis).all_items_count).to eql(@initial_all_items_count) #rg-checked
      end

      it "reduces the number of unsaved items in the cart to zero" do
        expect(@initial_now_count).to be > 0 #rg-checked
        expect(assigns(:cart_chassis).now_items_count).to eql(0) #rg-checked
      end

      it "increases the number of saved items by the number of previously-active items" do
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_later_count + @initial_now_count) #rg-checked
      end

      it "results in a cart in which all items are saved items" do
        expect(assigns(:cart_chassis).all_items_count).to be > 0 #rg-checked
        expect(assigns(:cart_chassis).now_items_count).to eql(0) #rg-checked
      end
    end
  end

  describe "PATCH #move_all_saved_items_to_cart" do

    context "when the cart is empty" do

      before do
        @now_bin_id = empty_cart_chassis.now_bin.id
        @later_bin_id = empty_cart_chassis.later_bin.id
        @initial_item_count = empty_cart_chassis.all_items_count

        sign_in(empty_user)
        patch :move_all_saved_items_to_cart
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not destroy the CartChassis object, or either of the bins" do
        expect(assigns(:cart_chassis)).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin.id).to eql(@now_bin_id) #rg-checked
        expect(assigns(:cart_chassis).later_bin.id).to eql(@later_bin_id) #rg-checked
      end

      it "ends with the cart completely empty" do
        #Validation of the test:
        expect(assigns(:cart_chassis).all_items_count).to eql(@initial_item_count) #rg-checked

        #actual test:
        expect(assigns(:cart_chassis).all_items_count).to eql(0) #rg-checked
      end
    end

    context "when the cart has only basic items" do

      before do
        @now_bin_id = existing_cart_chassis.now_bin.id
        @later_bin_id = existing_cart_chassis.later_bin.id
        @initial_now_count = existing_cart_chassis.now_items_count
        @initial_later_count = existing_cart_chassis.later_items_count

        sign_in(existing_user)
        patch :move_all_saved_items_to_cart
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not destroy the CartChassis object, or either of the bins" do
        expect(assigns(:cart_chassis)).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin.id).to eql(@now_bin_id) #rg-checked
        expect(assigns(:cart_chassis).later_bin.id).to eql(@later_bin_id) #rg-checked
      end

      it "does not change the total number of CartItems in the cart" do
        expect(assigns(:cart_chassis).all_items_count).to eql(@initial_now_count + @initial_later_count) #rg-checked
      end

      it "reduces the number of saved items in the cart to zero" do
        expect(@initial_later_count).to be > 0 #rg-checked
        expect(assigns(:cart_chassis).later_items_count).to eql(0) #rg-checked
      end

      it "increases the number of saved items by the number of previously-active items" do
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_later_count + @initial_now_count) #rg-checked
      end

      it "results in a cart in which all items are items-for-now" do
        expect(assigns(:cart_chassis).all_items_count).to be > 0 #rg-checked
        expect(assigns(:cart_chassis).later_items_count).to eql(0) #rg-checked
      end
    end

    context "when the cart contains only items-for-later" do
      before do
        @now_bin_id = saved_only_cart_chassis.now_bin.id
        @later_bin_id = saved_only_cart_chassis.later_bin.id
        @initial_now_count = saved_only_cart_chassis.now_items_count
        @initial_later_count = saved_only_cart_chassis.later_items_count
        @initial_all_items_count = saved_only_cart_chassis.all_items_count

        sign_in(saved_only_user)
        patch :save_all_items_for_later
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "does not destroy the CartChassis object, or either of the bins" do
        expect(assigns(:cart_chassis)).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).later_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin.id).to eql(@now_bin_id) #rg-checked
        expect(assigns(:cart_chassis).later_bin.id).to eql(@later_bin_id) #rg-checked
      end

      it "does not change the total number of CartItems in the cart" do
        expect(assigns(:cart_chassis).all_items_count).to eql(@initial_all_items_count) #rg-checked
      end

      it "results in a cart in which all items are saved for later" do
        expect(assigns(:cart_chassis).all_items_count).to be > 0 #rg-checked
        expect(assigns(:cart_chassis).now_items_count).to eql(0) #rg-checked
      end

      it "results in no change in the initial numbers of items-for-later and items-for-now" do
        expect(assigns(:cart_chassis).now_items_count).to eql(@initial_now_count) #rg-checked
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_later_count) #rg-checked
      end
    end

    context "when the cart's later_bin contains an invalid item" do
      before do
        whatevs_item.update_attribute(:item_price_memo, "some price")
        whatevs_item.update_attribute(:cart, existing_cart_chassis.later_bin)

        @now_bin_id = existing_cart_chassis.now_bin.id
        @later_bin_id = existing_cart_chassis.later_bin.id
        @initial_now_count = existing_cart_chassis.now_items_count
        @initial_later_count = existing_cart_chassis.later_items_count
        @initial_all_items_count = existing_cart_chassis.all_items_count

        sign_in(existing_user)
        patch :save_all_items_for_later
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "does not destroy the CartChassis object, or either of the bins" do
        expect(assigns(:cart_chassis)).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin).not_to be_nil #rg-checked
        expect(assigns(:cart_chassis).now_bin.id).to eql(@now_bin_id) #rg-checked
        expect(assigns(:cart_chassis).later_bin.id).to eql(@later_bin_id) #rg-checked
      end

      it "does not change the total number of CartItems in the cart" do
        expect(assigns(:cart_chassis).all_items_count).to eql(@initial_all_items_count) #rg-checked
      end

      it "increases the number of for-later items by the previous number of for-now items" do
        expect(assigns(:cart_chassis).later_items_count).to eql(@initial_now_count + @initial_later_count) #rg-checked
      end

      it "results in a cart in which all items are for-later" do
        expect(assigns(:cart_chassis).all_items_count).to be > 0 #rg-checked
        expect(assigns(:cart_chassis).now_items_count).to eql(0) #rg-checked
      end
    end
  end

  describe "PATCH #verify_single_item_availability" do

    context "when the item is basic" do

      before do
        @test_item = existing_cart_chassis.now_items.sample
        @test_item_id = @test_item.id

        sign_in(existing_user)
        patch :verify_single_item_availability, params: {
          :id => @test_item_id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash notice about the item being available" do
        expect(subject).to set_flash[:notice].to(/good news/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "ends with the target item having its 'available' attribute set to true" do
        #Test validation:
        expect(@test_item).to eql(assigns(:target_item))

        #Actual test:
        expect(assigns(:target_item).available).to eql(true) #rg-checked
      end
    end

    context "when the item is saved-for-later" do

      before do
        @test_item = existing_cart_chassis.later_items.sample

        sign_in(existing_user)
        patch :verify_single_item_availability, params: {
          :id => @test_item.id
        }
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a positive flash notice" do
        expect(subject).to set_flash[:notice].to(/good news/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "ends with the target item having its 'available' attribute set to true" do
        #Test validation:
        expect(@test_item.id).to eql(assigns(:target_item).id) #rg-checked

        #Actual test:
        expect(assigns(:target_item).available).to eql(true) #rg-checked
      end
    end

    context "when the item is expired" do
      before do
        expired_item.update_attribute(:cart, existing_cart_chassis.now_bin)
        @initial_exp_item_availability = expired_item.available

        sign_in(existing_user)
        patch :verify_single_item_availability, params: {
          :id => expired_item.id
        }
      end

      it "has a properly set-up test" do
        expect(existing_cart_chassis.now_items.include?(expired_item)).to eql(true) #rg-checked
        expect(expired_item.acquirable.active_to.present?).to eql(true) #rg-checked
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "ends with the target item having its 'available' attribute changed to false" do
        expect(@initial_exp_item_availability).to eql(true) #rg-checked
        expect(expired_item.id).not_to eql(assigns(:target_item).id + 100000) #perturbed
        expect(assigns(:target_item).available).to eql(false) #rg-checked
      end
    end

    context "when the items's item_name_memo doesn't match its acquirable's name" do
      before do
        name_altered_item.update_attribute(:cart, existing_cart_chassis.now_bin)
        @initial_n_alt_item_availability = name_altered_item.available

        sign_in(existing_user)
        patch :verify_single_item_availability, params: {
          :id => name_altered_item.id
        }
      end

      it "has a properly set-up test" do
        expect(existing_cart_chassis.now_items.include?(name_altered_item)).to eql(true) #rg-checked
        expect(name_altered_item.acquirable.name).not_to eql(name_altered_item.item_name_memo) #rg-checked
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "ends with the target item having its 'available' attribute changed to false" do
        expect(@initial_n_alt_item_availability).to eql(true) #rg-checked
        expect(name_altered_item.id).to eql(assigns(:target_item).id) #rg-checked
        expect(assigns(:target_item).available).to eql(false) #rg-checked
      end
    end

    context "when the item's item_price_memo doesn't match its acquirable's price" do

      before do
        price_altered_item.update_attribute(:cart, existing_cart_chassis.now_bin)
        @initial_p_alt_item_availability = price_altered_item.available

        sign_in(existing_user)
        patch :verify_single_item_availability, params: {
          :id => price_altered_item.id
        }
      end

      it "has a properly set-up test" do
        expect(existing_cart_chassis.now_items.include?(price_altered_item)).to eql(true) #rg-checked
        expect(price_altered_item.acquirable.price_cents).not_to eql(price_altered_item.item_price_memo) #rg-checked
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "ends with the target item having its 'available' attribute changed to false" do
        expect(@initial_p_alt_item_availability).to eql(true) #rg-checked
        expect(price_altered_item.id).to eql(assigns(:target_item).id) #rg-checked
        expect(assigns(:target_item).available).to eql(false) #rg-checked
      end
    end

    context "when the item has an unknown kind" do

      before do
        unknown_kind_item.update_attribute(:cart, existing_cart_chassis.now_bin)
        @u_k_item_initial_availability = unknown_kind_item.available

        sign_in(existing_user)
        patch :verify_single_item_availability, params: {
          :id => unknown_kind_item.id
        }
      end

      it "has a properly set-up test" do
        expect(existing_cart_chassis.now_items.include?(unknown_kind_item)).to eql(true)  #rg-checked
        expect(unknown_kind_item.kind).to eql(CartItem::UNKNOWN) #rg-checked
      end

      it "succeeds" do
        expect(response).to have_http_status(:found)  #rg-checked
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i)  #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart)  #rg-checked
      end

      it "ends with the target item having its 'available' attribute changed to false" do
        expect(@u_k_item_initial_availability).to eql(true)  #rg-checked
        expect(unknown_kind_item.id).to eql(assigns(:target_item).id) #rg-checked
        expect(assigns(:target_item).available).to eql(false) #rg-checked
      end
    end

    context "when the item is already marked unavailable" do
      before do
        unavailable_item.update_attribute(:cart, existing_cart_chassis.now_bin)
        @unavail_item_initial_availability = unavailable_item.available

        sign_in(existing_user)
        patch :verify_single_item_availability, params: {
          :id => unavailable_item.id
        }
      end

      it "has a properly set-up test" do
        expect(existing_cart_chassis.now_items.include?(unavailable_item)).to eql(true)  #rg-checked
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "ends no change to the item's 'available' attribute" do
        expect(@unavail_item_initial_availability).to eql(false) #rg-checked
        expect(unavailable_item.id).to eql(assigns(:target_item).id) #rg-checked
        expect(assigns(:target_item).available).to eql(false) #rg-checked
      end
    end

    context "when the item is not in the user's cart" do

      before do
        @original_whatevs_bin = whatevs_item.cart
        @original_whatevs_item_availability = whatevs_item.available

        sign_in(existing_user)
        patch :verify_single_item_availability, params: {
          :id => whatevs_item.id
        }
      end

      it "has a properly set-up test" do
        expect(existing_cart_chassis.now_items.include?(whatevs_item)).to eql(false)  #rg-checked
        expect(existing_cart_chassis.later_items.include?(whatevs_item)).to eql(false)  #rg-checked
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i) #rg-checked
      end

      it "does not change the value of the item's 'available' attribute" do
        expect(@original_whatevs_item_availability).to eql(whatevs_item.available) #rg-checked
      end

      it "does not assign a value assigned to the @target_item instance variable" do
        expect(assigns(:target_item)).to be_nil #rg-checked
      end
    end

    context "when the item no longer exists" do

      before do
        @condemned_item = existing_cart_chassis.now_items.sample
        @condemned_item_id = @condemned_item.id
        @condemned_item.destroy
        existing_cart_chassis.full_reload

        sign_in(existing_user)
        patch :verify_single_item_availability, params: {
          :id => @condemned_item_id
        }
      end

      it "has a properly set-up test" do
        expect { @condemned_item.reload}.to raise_error #rg-checked

        found_now_items = existing_cart_chassis.now_items.select {|i| i.id == @condemned_item_id }
        found_later_items = existing_cart_chassis.later_items.select {|i| i.id == @condemned_item_id }
        expect(found_now_items.length + found_later_items.length).to eql(0) #rg-checked
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/unable to recognize/i) #rg-checked
      end

      it "does not assign a value assigned to the @target_item instance variable" do
        expect(assigns(:target_item)).to be_nil #rg-checked
      end
    end
  end

  describe "PATCH #verify_all_items_availability" do

    context "when the cart is empty" do
      before do
        @init_now_count = empty_cart_chassis.now_items_count
        @init_later_count = empty_cart_chassis.later_items_count

        sign_in(empty_user)
        patch :verify_all_items_availability
      end

      it "has a properly set up test" do
        expect(@init_now_count + @init_later_count).to eql(0) #rg-checked
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:alert].to(/no items were detected/i) #rg-checked
      end
    end

    context "when the cart contains only basic items" do

      before do
        @found_now_unavails = existing_cart_chassis.now_items.select {|i| !i.available }
        @found_later_unavails = existing_cart_chassis.later_items.select {|i| !i.available }
        sign_in(existing_user)
        patch :verify_all_items_availability
      end

      it "has a properly set-up test" do
        expect(@found_now_unavails.length).to eql(0) #rg-checked
        expect(@found_later_unavails.length).to eql(0) #rg-checked
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "sets a flash notice" do
        expect(subject).to set_flash[:notice].to(/good news/i) #rg-checked
      end

      it "does not change the number of items in the cart marked unavailable" do
        found_unavail_nows = existing_cart_chassis.now_items.select {|i| !i.available }
        found_unavail_laters = existing_cart_chassis.later_items.select {|i| !i.available }
        expect(found_unavail_nows.length + found_unavail_laters.length).to eql(0) #rg-checked
        expect(found_unavail_nows.length + found_unavail_laters.length).to eql(@found_now_unavails.length + @found_later_unavails.length) #rg-checked
      end
    end

    context "when the cart contains an expired item" do

      before do
        expired_item.update_attribute(:cart, existing_cart_chassis.now_bin)
        @found_now_unavails = existing_cart_chassis.now_items.select {|i| !i.available }
        @found_later_unavails = existing_cart_chassis.later_items.select {|i| !i.available }

        sign_in(existing_user)
        patch :verify_all_items_availability
      end

      it "has a properly set-up test" do
        expect(existing_cart_chassis.now_items.include?(expired_item)).to eql(true) #rg-checked
        expect(@found_now_unavails.length).to eql(0) #rg-checked
        expect(@found_later_unavails.length).to eql(0) #rg-checked
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "sets a flash alert" do
        expect(subject).to set_flash[:alert].to(/no longer/i) #rg-checked
      end

      it "increases the number of items in the cart marked unavailable by one" do
        existing_cart_chassis.full_reload
        found_unavail_nows = existing_cart_chassis.now_items.select {|i| !i.available }
        found_unavail_laters = existing_cart_chassis.later_items.select {|i| !i.available }
        expect(found_unavail_nows.length + found_unavail_laters.length).to eql(@found_now_unavails.length + @found_later_unavails.length + 1) #rg-checked
      end
    end
  end

  describe "GET #preview_online_purchase" do
    context "When there is nothing in the now_bin" do
      before do
        sign_in(saved_only_user)
        get :preview_online_purchase
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:notice].to(/nothing in your cart/i) #rg-checked
      end

      it "does not set a value for @expected_charge" do
        expect(assigns(:expected_charge)).to be_nil #rg-checked
      end

      it "does not set a value for @items_for_purchase" do
        expect(assigns(:items_for_purchase)).to be_nil #rg-checked
      end
    end

    context "when there are only basic items in the now_bin" do
      before do
        sign_in(existing_user)
        get :preview_online_purchase
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok) #rg-checked
      end

      it "renders" do
        expect(subject).to render_template(:preview_online_purchase) #rg-checked
      end

      it "sets a value for @expected_charge" do
        expect(assigns(:expected_charge)).to be #rg-checked
        expect(assigns(:expected_charge)).to be_a_kind_of(String) #rg-checked
      end

      it "sets a value for @items_for_purchase" do
        expect(assigns(:items_for_purchase)).to be #rg-checked
        expect(assigns(:items_for_purchase)).to be_a_kind_of(Array) #rg-checked
        expect(assigns(:items_for_purchase).length).to eql(assigns(:cart_chassis).now_items_count) #rg-checked
        test_item = assigns(:cart_chassis).now_items.sample
        expect(assigns(:items_for_purchase).include?(test_item)).to eql(true) #rg-checked
      end
    end

    context "when there is an invalid item in the now_bin" do
      before do
        price_altered_item.update_attribute(:cart, existing_cart_chassis.now_bin)
        sign_in(existing_user)
        get :preview_online_purchase
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:alert].to(/problem/i) #rg-checked
      end

      it "does not set a value for @expected_charge" do
        expect(assigns(:expected_charge)).to be_nil #rg-checked
      end

      it "does not set a value for @items_for_purchase" do
        expect(assigns(:items_for_purchase)).to be_nil #rg-checked
      end
    end

    context "when there is an expired item in the now_bin" do
      before do
        expired_item.update_attribute(:cart, existing_cart_chassis.now_bin)

        sign_in(existing_user)
        get :preview_online_purchase
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:alert].to(/problem/i) #rg-checked
      end

      it "does not set a value for @expected_charge" do
        expect(assigns(:expected_charge)).to be_nil #rg-checked
      end

      it "does not set a value for @items_for_purchase" do
        expect(assigns(:items_for_purchase)).to be_nil #rg-checked
      end
    end

    context "when there is an expired item in the later_bin" do
      before do
        expired_item.update_attribute(:cart, existing_cart_chassis.later_bin)

        sign_in(existing_user)
        get :preview_online_purchase
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok) #rg-checked
      end

      it "renders" do
        expect(subject).to render_template(:preview_online_purchase) #rg-checked
      end

      it "sets a value for @expected_charge" do
        expect(assigns(:expected_charge)).to be #rg-checked
        expect(assigns(:expected_charge)).to be_a_kind_of(String) #rg-checked
      end

      it "sets a value for @items_for_purchase" do
        expect(assigns(:items_for_purchase)).to be #rg-checked
        expect(assigns(:items_for_purchase)).to be_a_kind_of(Array) #rg-checked
        expect(assigns(:items_for_purchase).length).to eql(assigns(:cart_chassis).now_items_count) #rg-checked
        test_item = assigns(:cart_chassis).now_items.sample
        expect(assigns(:items_for_purchase).include?(test_item)).to eql(true) #rg-checked
      end
    end
  end

  describe "POST #submit_online_payment" do
    context "When there is nothing in the now_bin" do
      before do
        sign_in(saved_only_user)
        post :submit_online_payment
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:reservations) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:notice].to(/nothing in your cart/i) #rg-checked
      end

      it "does not set a value for @transaction_cart" do
        expect(assigns(:transaction_cart)).to be_nil #rg-checked
      end

      it "does not set a value for @prospective_charge_cents" do
        expect(assigns(:prospective_charge_cents)).to be_nil #rg-checked
      end
    end

    context "when the now_bin contains only free items" do
      before do
        free_item.update_attribute(:cart, empty_cart_chassis.now_bin)
        @free_item_has_holdable = free_item.holdable.present?
        sign_in(empty_user)
        post :submit_online_payment
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:reservations) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:notice].to(/no payment is required/i) #rg-checked
      end

      it "adds a holdable to the free item" do
        expect(@free_item_has_holdable).to eql(false) #rg-checked
        free_item.reload
        expect(free_item.holdable.present?).to eql(true) #rg-checked
      end

      it "does not set a value for @transaction_cart" do
        expect(assigns(:transaction_cart)).to be_nil #rg-checked
      end

      it "does not set a value for @prospective_charge_cents" do
        expect(assigns(:prospective_charge_cents)).to be_nil #rg-checked
      end
    end

    context "when the now_bin contains only items with fully-paid reservations" do
      before do
        @sample_item = paid_reservations_chassis.now_items.sample
        @sample_item_holdable = @sample_item.holdable

        sign_in(paid_reservations_user)
        post :submit_online_payment
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:reservations) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:notice].to(/no payment is required/i) #rg-checked
      end

      it "leaves the cart_items' holdables in place" do
        expect(@sample_item_holdable).to be #rg-checked
        @sample_item.reload
        expect(@sample_item_holdable).to eql(@sample_item.holdable) #rg-checked
      end

      it "does not set a value for @transaction_cart" do
        expect(assigns(:transaction_cart)).to be_nil #rg-checked
      end

      it "does not set a value for @prospective_charge_cents" do
        expect(assigns(:prospective_charge_cents)).to be_nil #rg-checked
      end
    end

    context "when the now_bin contains only items with partially-paid reservations" do
      before do
        @sample_item = part_paid_res_chassis.now_items.sample
        @sample_item_holdable = @sample_item.holdable

        sign_in(part_paid_res_user)
        post :submit_online_payment
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok) #rg-checked
      end

      it "renders" do
        expect(subject).to render_template(:submit_online_payment) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:notice].to(/requested reservations/i)  #rg-checked
      end

      it "leaves the cart_items' holdables in place" do
        expect(@sample_item_holdable).to be  #rg-checked
        @sample_item.reload
        expect(@sample_item_holdable).to eql(@sample_item.holdable)  #rg-checked
      end

      it "sets a nonzero value for @prospective_charge_cents" do
        expect(assigns(:prospective_charge_cents)).not_to be_nil #rg-checked
        expect(assigns(:prospective_charge_cents)).to be_a_kind_of(Numeric) #rg-checked
        expect(assigns(:prospective_charge_cents)).to be > 0 #rg-checked
      end

      it "assigns the now_bin to @transaction_cart" do
        expect(assigns(:transaction_cart)).not_to be_nil #rg-checked
        expect(part_paid_res_chassis.now_bin).to eql(assigns(:transaction_cart)) #rg-checked
      end
    end

    context "when there are only basic membership items in the now_bin" do
      before do
        @sample_item = existing_cart_chassis.now_items.sample
        @sample_has_holdable = @sample_item.holdable.present?
        sign_in(existing_user)
        post :submit_online_payment
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok) #rg-checked
      end

      it "renders" do
        expect(subject).to render_template(:submit_online_payment) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:notice].to(/requested reservations/i)  #rg-checked
      end

      it "creates a holdable for each item" do
        expect(@sample_has_holdable).to eql(false) #rg-checked
        @sample_item.reload
        expect(@sample_item.holdable.present?).to eql(true) #rg-checked
      end

      it "sets a nonzero value for @prospective_charge_cents" do
        expect(assigns(:prospective_charge_cents)).not_to be_nil #rg-checked
        expect(assigns(:prospective_charge_cents)).to be_a_kind_of(Numeric) #rg-checked
        expect(assigns(:prospective_charge_cents)).to be > 0 #rg-checked
      end

      it "assigns the now_bin to @transaction_cart" do
        expect(assigns(:transaction_cart)).not_to be_nil #rg-checked
        expect(existing_cart_chassis.now_bin).to eql(assigns(:transaction_cart)) #rg-checked
      end
    end

    context "when there is an invalid item in the now_bin" do
      before do
        price_altered_item.update_attribute(:cart, existing_cart_chassis.now_bin)
        sign_in(existing_user)
        post :submit_online_payment
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:alert].to(/problems/i)  #rg-checked
         expect(subject).to set_flash[:notice].to(/review/i)  #rg-checked
      end

      it "does not set a value for @prospective_charge_cents" do
        expect(assigns(:prospective_charge_cents)).to be_nil #rg-checked
      end

      it "does not set a value for @transaction_cart" do
        expect(assigns(:transaction_cart)).to be_nil #rg-checked
      end
    end

    context "when there is an expired item in the now_bin" do
      before do
        expired_item.update_attribute(:cart, existing_cart_chassis.now_bin)

        sign_in(existing_user)
        post :submit_online_payment
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:alert].to(/problems/i)  #rg-checked
         expect(subject).to set_flash[:notice].to(/review/i)  #rg-checked
      end

      it "does not set a value for @prospective_charge_cents" do
        expect(assigns(:prospective_charge_cents)).to be_nil #rg-checked
      end

      it "does not set a value for @transaction_cart" do
        expect(assigns(:transaction_cart)).to be_nil #rg-checked
      end
    end

    context "when there is an expired item in the later_bin" do
      before do
        @sample_item = existing_cart_chassis.now_items.sample
        @sample_has_holdable = @sample_item.holdable.present?

        expired_item.update_attribute(:cart, existing_cart_chassis.later_bin)

        sign_in(existing_user)
        get :submit_online_payment
      end

      it "succeeds" do
        expect(response).to have_http_status(:ok) #rg-checked
      end

      it "renders" do
        expect(subject).to render_template(:submit_online_payment) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:notice].to(/requested reservations/i)  #rg-checked
      end

      it "creates a holdable for each item" do
        expect(@sample_has_holdable).to eql(false) #rg-checked
        @sample_item.reload
        expect(@sample_item.holdable.present?).to eql(true)  #rg-checked
      end

      it "sets a nonzero value for @prospective_charge_cents" do
        expect(assigns(:prospective_charge_cents)).not_to be_nil  #rg-checked
        expect(assigns(:prospective_charge_cents)).to be_a_kind_of(Numeric)  #rg-checked
        expect(assigns(:prospective_charge_cents)).to be > 0  #rg-checked
      end

      it "assigns the now_bin to @transaction_cart" do
        expect(assigns(:transaction_cart)).not_to be_nil  #rg-checked
        expect(existing_cart_chassis.now_bin).to eql(assigns(:transaction_cart)) #rg-checked
      end
    end
  end

  describe "POST #pay_with_cheque" do
    context "When there is nothing in the now_bin" do
      before do
        sign_in(saved_only_user)
        post :pay_with_cheque
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:reservations) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:notice].to(/nothing in your cart/i) #rg-checked
      end
    end

    context "when the now_bin contains only free items" do
      before do
        free_item.update_attribute(:cart, empty_cart_chassis.now_bin)
        @free_item_has_holdable = free_item.holdable.present?
        sign_in(empty_user)
        post :pay_with_cheque
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:reservations) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:notice].to(/no payment is required/i) #rg-checked
      end

      it "adds a holdable to the free item" do
        expect(@free_item_has_holdable).to eql(false) #rg-checked
        free_item.reload
        expect(free_item.holdable.present?).to eql(true) #rg-checked
      end
    end

    context "when the now_bin contains only items with fully-paid reservations" do
      before do
        @sample_item = paid_reservations_chassis.now_items.sample
        @sample_item_holdable = @sample_item.holdable

        sign_in(paid_reservations_user)
        post :pay_with_cheque
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:reservations) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:notice].to(/no payment is required/i) #rg-checked
      end

      it "leaves the cart_items' holdables in place" do
        expect(@sample_item_holdable).to be #rg-checked
        @sample_item.reload
        expect(@sample_item_holdable).to eql(@sample_item.holdable) #rg-checked
      end
    end

    context "when the now_bin contains only items with partially-paid reservations" do
      before do
        @sample_item = part_paid_res_chassis.now_items.sample
        @sample_item_holdable = @sample_item.holdable

        sign_in(part_paid_res_user)
        post :pay_with_cheque
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:reservations) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:notice].to(/requested reservations/i)   #rg-checked
      end

      it "leaves the cart_items' holdables in place" do
        expect(@sample_item_holdable).to be  #rg-checked
        @sample_item.reload
        expect(@sample_item_holdable).to eql(@sample_item.holdable)  #rg-checked
      end
    end

    context "when there are only basic membership items in the now_bin" do
      before do
        @sample_item = existing_cart_chassis.now_items.sample
        @sample_has_holdable = @sample_item.holdable.present?
        sign_in(existing_user)
        post :pay_with_cheque
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:reservations) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:notice].to(/requested reservations/i)  #rg-checked
      end

      it "creates a holdable for each item" do
        expect(@sample_has_holdable).to eql(false) #rg-checked
        @sample_item.reload
        expect(@sample_item.holdable.present?).to eql(true) #rg-checked
      end
    end

    context "when there is an invalid item in the now_bin" do
      before do
        price_altered_item.update_attribute(:cart, existing_cart_chassis.now_bin)
        sign_in(existing_user)
        post :pay_with_cheque
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:alert].to(/problems/i)  #rg-checked
         expect(subject).to set_flash[:notice].to(/review/i)  #rg-checked
      end
    end

    context "when there is an expired item in the now_bin" do
      before do
        expired_item.update_attribute(:cart, existing_cart_chassis.now_bin)

        sign_in(existing_user)
        post :pay_with_cheque
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:cart) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:alert].to(/problems/i)  #rg-checked
         expect(subject).to set_flash[:notice].to(/review/i) #rg-checked
      end
    end

    context "when there is an expired item in the later_bin" do
      before do
        @sample_item = existing_cart_chassis.now_items.sample
        @sample_has_holdable = @sample_item.holdable.present?

        expired_item.update_attribute(:cart, existing_cart_chassis.later_bin)

        sign_in(existing_user)
        get :pay_with_cheque
      end

      it "succeeds" do
        expect(response).to have_http_status(:found) #rg-checked
      end

      it "redirects" do
        expect(subject).to redirect_to(:reservations) #rg-checked
      end

      it "sets a flash notice" do
         expect(subject).to set_flash[:notice].to(/requested reservations/i)  #rg-checked
      end

      it "creates a holdable for each item" do
        expect(@sample_has_holdable).to eql(false) #rg-checked
        @sample_item.reload
        expect(@sample_item.holdable.present?).to eql(true)  #rg-checked
      end
    end
  end
end
