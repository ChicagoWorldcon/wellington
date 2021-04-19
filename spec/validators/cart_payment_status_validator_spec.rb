# frozen_string_literal: true
#
# Copyright 2020 Victoria Garcia
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

require 'spec_helper'
require 'rails_helper'
require 'active_model'

class ValidationPotato
  include ActiveModel::Model
  include ActiveModel::Validations
  include ActiveScopes
  include Buyable

  attr_accessor :status, :cart_items, :charges, :active_to
  attr_reader :active_from

  def initialize(status: Cart::FOR_NOW, cart_item_ary: [], charge_ary: [], still_active: true)
    @status = status
    @cart_items = cart_item_ary
    @charges = charge_ary
    @active_from = 1.week.ago
    @active_to = still_active ? 1.day.ago : nil
  end

  validates_with CartPaymentStatusValidator
end

RSpec.describe CartPaymentStatusValidator do
  DEFAULT_CART_ITEM_COUNT = 3
  DEFAULT_C_ITEM_COUNT_CUBED = DEFAULT_CART_ITEM_COUNT**3
  ADULT_MEMBERSHIP_PRICE_CENTS = build(:membership, :adult).price_cents
  DEFAULT_SMALL_CHARGE = ADULT_MEMBERSHIP_PRICE_CENTS / (DEFAULT_C_ITEM_COUNT_CUBED * 2)

  let(:whatevs_cart) = create(:cart) #Just a placeholder for valid cart_item creation. Not used (or relevant) in this spec

  let(:paid_cart_item_ary) { create_list(:cart_item, DEFAULT_CART_ITEM_COUNT, :with_paid_reservation, cart: whatevs_cart)}
  let(:partially_paid_cart_item_ary) create_list(:cart_item, DEFAULT_CART_ITEM_COUNT, :with_partially_paid_reservation, cart: whatevs_cart)

  let(:basic_cart_item_ary) { create_list(:cart_item, DEFAULT_CART_ITEM_COUNT, cart: whatevs_cart)}
  let(:basic_free_cart_item_ary) { create_list(:cart_item, DEFAULT_CART_ITEM_COUNT, :with_free_membership, cart: whatevs_cart)}

  let(:successful_small_charges) { create_list(:charge, DEFAULT_CART_ITEM_COUNT - 1, amount_cents: DEFAULT_SMALL_CHARGE)}
  let(:successful_full_membership_charges) { create_list(:charge, DEFAULT_CART_ITEM_COUNT, amount_cents: ADULT_MEMBERSHIP_PRICE_CENTS)}

  let(:lots_of_successful_full_membership_charges) { create_list(:charge, DEFAULT_C_ITEM_COUNT_CUBED , amount_cents: ADULT_MEMBERSHIP_PRICE_CENTS)}
  let(:lots_of_pending_full_membership_charges) { create_list(:charge, DEFAULT_C_ITEM_COUNT_CUBED , amount_cents: ADULT_MEMBERSHIP_PRICE_CENTS, state: Charge::STATE_PENDING)}
  let(:lots_of_failed_full_membership_charges) { create_list(:charge, DEFAULT_C_ITEM_COUNT_CUBED, :failed, amount_cents: ADULT_MEMBERSHIP_PRICE_CENTS)}

  let(:one_successful_membership_charge) { create_list(:charge, 1, amount_cents: ADULT_MEMBERSHIP_PRICE_CENTS) }
  let(:one_successful_small_charge) {  create_list(:charge, 1, amount_cents: DEFAULT_SMALL_CHARGE) }


  context "when the cart has no charges of its own" do
    context "when the cart contains no items" do
      subject { ValidationPotato.new() }

      context "when we're pre-validating the following round of tests" do
        xit 'has a test that is properly set up' do
          expect(subject).to be
          expect(subject.cart_items.blank?).to be_truthy
          expect(subject.charges.blank?).to be_truthy
          expect(subject.active?).to be_truthy
        end
      end

      context "when the status is for_now" do
        xit "its status is set to 'for_now" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "its status is set to 'for_later'" do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "its status is set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "its status is set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          expect(subject.errors.size).to eq(1)
        end
      end
    end

    context "when the cart contains only free items without holdables" do
      subject { ValidationPotato.new(cart_item_ary: basic_free_cart_item_ary) }

      context "when we're pre-validating the tests" do

        xit 'has a test cart that is properly set up' do
          expect(subject).to be
          expect(subject.cart_items.present?).to be_truthy
          expect(subject.charges.blank?).to be_truthy
          expect(subject.active?).to be_truthy

          cart_items_with_nonzero_prices_seen = false
          cart_items_with_holdables_seen = false

          subject.cart_items.each do |i|
            cart_items_with_nonzero_prices_seen = true if (i.price_cents.present? && i.price_cents > 0)
            cart_items_with_holdables_seen = true if i.holdable.present?
          end

          expect(cart_items_with_nonzero_prices_seen).to be_falsey
          expect(cart_items_with_holdables_seen).to be_falsey
        end
      end

      context "when the status is for_now" do
        xit "has has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status attribute set to 'for_later' " do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          expect(subject.errors.size).to eq(1)
        end
      end
    end

    context "when the cart contains only non-free items with no holdables or succesful charges of their own" do
      subject { ValidationPotato.new(cart_item_ary: basic_cart_item_ary) }

      context "when we're pre-validating this test group" do

        xit 'has a test cart that is properly set up' do
          expect(subject).to be
          expect(subject.cart_items.present?).to be_truthy
          expect(subject.charges.blank?).to be_truthy
          expect(subject.active?).to be_truthy

          succesful_cart_item_charges_seen = false
          free_cart_items_seen = false
          cart_items_with_holdables_seen = false

          subject.cart_items.each do |i|
            succesful_cart_item_charges_seen = true if i.charges.present?
            cart_items_with_nonzero_prices_seen += 1 if !i.price_cents.present? || i.price_cents > 0)
            cart_items_with_holdables_seen = true if i.holdable.present?
          end

          expect(succesful_cart_item_charges_seen).to be_falsey
          expect(cart_items_with_holdables_seen).to be_falsey
          expect(cart_items_with_nonzero_prices_seen).to be_falsey
        end
      end

      context "when the status is for_now" do
        xit "has has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status attribute set to 'for_later' " do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          expect(subject.errors.size).to eq(1)
        end
      end
    end

    context "when the cart contains exclusively items that are partially paid through charges of their own" do
      subject { ValidationPotato.new(cart_item_ary: :partially_paid_cart_item_ary) }

      context "when we're pre-validating the tests group" do

        xit 'has a test cart that is properly set up' do
          expect(subject).to be
          expect(subject.cart_items.present?).to be_truthy
          expect(subject.charges.blank?).to be_truthy
          expect(subject.active?).to be_truthy

          cart_item_without_successful_charges_seen = false
          cart_items_without_holdables_seen = false
          fully_paid_cart_items_seen = false

          subject.cart_items.each do |i|
            cart_items_without_successful_charges_seen = true if !i.successful_direct_charges?
            cart_items_without_holdables_seen = true if i.holdable.blank?
            fully_paid_cart_items_seen = true if (i.holdable.present? && AmountOwedForReservation.new(i.holdable).amount_owed > 0)
          end

          expect(cart_items_without_successful_charges_seen).to be_falsey
          expect(cart_items_without_holdables_seen_count).to be_falsey
          expect(fully_paid_cart_items_seen).to be_falsey
        end
      end

      context "when the status is for_now" do
        xit "has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status set to 'for_later'" do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is valid' do
          subject.valid?
          expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          expect(subject).not_to be_valid
        end

        xit 'has 1 error' do
          subject.valid?
          expect(subject.errors.size).to eq(1)
        end
      end
    end

    context "when the cart contains a mix of items that are fully paid through charges of their own and items with no charges" do
      subject { ValidationPotato.new(cart_item_ary: :paid_cart_item_ary + :basic_cart_item_ary) }

      context "when we're pre-validating the test-group" do

        xit 'has a test cart that is properly set up' do
          expect(subject).to be
          expect(subject.cart_items.present?).to be_truthy
          expect(subject.charges.blank?).to be_truthy
          expect(subject.active?).to be_truthy

          cart_item_without_successful_charges_seen = false
          fully_paid_cart_items_seen = false
          cart_items_without_holdables_seen = false
          cart_items_with_holdables_seen = false

          subject.cart_items.each do |i|
            cart_items_without_successful_charges_seen = true if !i.successful_direct_charges?
            fully_paid_cart_items_seen = true if (i.holdable.present? && AmountOwedForReservation.new(i.holdable).amount_owed <= 0)
            i.holdable.blank? ? ( cart_items_without_holdables_seen = true ) : ( cart_items_with_holdables_seen = true )
          end

          expect(cart_item_without_successful_charges_seen).to be_truthy
          expect(fully_paid_cart_items_seen).to be_truthy
          expect(cart_item_with_holdables_seen).to be_truthy
          expect(cart_item_without_holdables_seen).to be_truthy
        end
      end

      context "when the status is for_now" do
        xit "has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status set to 'for_later'" do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          expect(subject).not_to be_valid
        end

        xit 'has 1 error' do
          subject.valid?
          expect(subject.errors.size).to eq(1)
        end
      end
    end

  context "when the cart has charges of its own, but all are failed or pending" do
    context "when the cart contains no items" do
      subject { ValidationPotato.new(charge_ary: :lots_of_failed_full_membership_charges + :lots_of_pending_full_membership_charges) }

      context "when we're pre-validating the test-group" do

        xit 'has a test-cart that is properly set up' do
          expect(subject).to be
          expect(subject.cart_items.blank?).to be_truthy
          expect(subject.charges.present?).to be_truthy
          expect(subject.successful_direct_charges?).to be_falsey
          expect(subject.active?).to be_truthy

          successful_charges_seen = false
          pending_charges_seen_count = 0
          failed_charges_seen_count = 0

          subject.charges.each do |i|
            successful_charges_seen = true if i.successful?
            pending_charges_seen_count += 1 if i.pending?
            failed_charges_seen_count += 1 if i.failed?
          end

          expect(successful_charges_seen).to be_falsey
          expect(pending_charges_seen_count).to be > 0
          expect(failed_charges_seen_count).to be > 0
          expect(pending_charges_seen_count + failed_charges_seen_count).to eql(subject.charges.size)
        end
      end

      context "when the status is for_now" do
        xit "has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status set to 'for_later'" do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is invalid' do
          subject.valid?
          expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          expect(subject).not_to be_valid
        end

        xit 'has 1 error' do
          subject.valid?
          expect(subject.errors.size).to eq(1)
        end
      end
    end

    context "when the cart contains only items with no charges of their own" do
      subject { ValidationPotato.new(charge_ary: :lots_of_failed_full_membership_charges + :lots_of_pending_full_membership_charges, cart_item_ary: :basic_cart_item_ary) }

      context "when we're pre-validating the test-group" do
        xit 'has a test-cart that is properly set up' do
          expect(subject).to be
          expect(subject.cart_items.present?).to be_truthy
          expect(subject.charges.present?).to be_truthy
          expect(subject.active?).to be_truthy

          successful_charges_seen = false
          pending_charges_seen = 0
          failed_charges_seen = 0
          cart_item_charges_seen = false

          subject.charges.each do |i|
            successful_charges_seen = true if i.successful?
            pending_charges_seen_count += 1 if i.pending?
            failed_charges_seen_count += 1 if i.failed?
            cart_item_charges_seen = true if i.charges.present?
          end

          expect(successful_charges_seen).to be_falsey
          expect(pending_charges_seen_count).to be > 0
          expect(failed_charges_seen_count).to be > 0
          expect(pending_charges_seen_count + failed_charges_seen_count).to eql(subject.charges.size)
        end
      end


      context "when the status is for_now" do
        xit "has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status set to 'for_later'" do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          #expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has 1 error' do
          subject.valid?
        #  expect(subject.errors.size).to eq(1)
        end
      end
    end

    context "when the cart contains exclusively items that are partially paid through charges of their own" do
      context "when the status is for_now" do
        xit "has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status set to 'for_later'" do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          #expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has 1 error' do
          subject.valid?
        #  expect(subject.errors.size).to eq(1)
        end
      end
    end

    context "when the cart contains exclusively items that are fully paid through charges of their own" do
      context "when the status is for_now" do
        xit "has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status set to 'for_later'" do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          #expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has 1 error' do
          subject.valid?
        #  expect(subject.errors.size).to eq(1)
        end
      end
    end
  end

  context "when the cart has successful, small charges of its own" do
    #TODO:  THIS SHOULD BE PREVENTED UPSTREAM!!!!!!!!!
    #TODO:  ONE **IMPORTANT*** IDEA-- PREVENT ITEMS FROM BEING ADDED TO A CART UNLESS THE CART IS active_for_now OR active_for_later

    context "when the cart's charges, combined with the cart_items' independent charges, are LESS THAN the price of the cart's contents" do

      context "when the status is for_now" do
        xit "has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status set to 'for_later'" do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          #expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has 1 error' do
          subject.valid?
        #  expect(subject.errors.size).to eq(1)
        end
      end
    end

    context "when the cart's charges, combined with the cart_items' independent charges, EQUAL the price of the cart's contents" do
      context "when the status is for_now" do
        xit "has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status set to 'for_later'" do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          #expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has 1 error' do
          subject.valid?
        #  expect(subject.errors.size).to eq(1)
        end
      end
    end

    context "when the cart's charges, combined with the cart_items' independent charges, EXCEED the price of the cart's contents" do
      #TODO:  THIS SHOULD BE PREVENTED UPSTREAM
      context "when the status is for_now" do
        xit "has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status set to 'for_later'" do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          #expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has 1 error' do
          subject.valid?
        #  expect(subject.errors.size).to eq(1)
        end
      end
    end
  end

  context "when the cart is fully paid through charges of its own" do
    context "when the cart contains only items with no charges of their own" do

      context "when the status is for_now" do
        xit "has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status set to 'for_later'" do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          #expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has 1 error' do
          subject.valid?
        #  expect(subject.errors.size).to eq(1)
        end
      end
    end

    context "when the cart contains items with some charges of their own" do



      context "when the status is for_now" do
        xit "has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status set to 'for_later'" do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          #expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has 1 error' do
          subject.valid?
        #  expect(subject.errors.size).to eq(1)
        end
      end
    end
  end

  context "when the cart itself has charges that EXCEED the price of its contents" do
    #TODO: FIGUIRE OUT IF THIS IS A THING. It shouldn't be.  Something has gone wrong upstream if this happens.
    context "when the cart contains no items" do

      context "when the status is for_now" do
        xit "has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status set to 'for_later'" do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          #expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has 1 error' do
          subject.valid?
        #  expect(subject.errors.size).to eq(1)
        end
      end
    end

    context "when the cart contains only items with no charges of their own" do

      context "when the status is for_now" do
        xit "has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status set to 'for_later'" do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          #expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has 1 error' do
          subject.valid?
        #  expect(subject.errors.size).to eq(1)
        end
      end
    end

    context "when the cart contains items with some charges of their own" do
      context "when the status is for_now" do
        xit "has its status set to 'for_now'" do
          expect(subject.status).to eql(Cart::FOR_NOW)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is for_later" do
        before(:each) do
          subject.update_attribute(:status, Cart::FOR_LATER)
        end

        xit "has its status set to 'for_later'" do
          expect(subject.status).to eql(Cart::FOR_LATER)
        end

        xit 'is valid' do
          subject.valid?
          #expect(subject).to be_valid
        end

        xit 'has no errors' do
          subject.valid?
          #expect(subject.errors.size).to eq(0)
        end
      end

      context "when the status is awaiting_cheque" do
        before(:each) do
          subject.update_attribute(:status, Cart::AWAITING_CHEQUE)
        end

        xit "has its status set to 'awaiting_cheque'" do
          expect(subject.status).to eql(Cart::AWAITING_CHEQUE)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has one error' do
          subject.valid?
          #expect(subject.errors.size).to eq(1)
        end
      end

      context "when the status is paid" do
        before(:each) do
          subject.update_attribute(:status, Cart::PAID)
        end

        xit "has its status set to 'paid'" do
          expect(subject.status).to eql(Cart::PAID)
        end

        xit 'is invalid' do
          subject.valid?
          #expect(subject).not_to be_valid
        end

        xit 'has 1 error' do
          subject.valid?
        #  expect(subject.errors.size).to eq(1)
        end
      end
    end
  end
end
