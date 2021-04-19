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

require 'spec_helper'
require 'rails_helper'
require 'active_model'

class ValidationSubstrate
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :acquirable, :item_name_memo, :item_price_memo, :kind

  def initialize(acquirable:, item_name_memo:, item_price_memo:)
    @kind = "Substrate"
    @acquirable = acquirable
    @item_name_memo = item_name_memo
    @item_price_memo = item_price_memo
  end

  validates_with PriceAndNameMemoValidator
end

RSpec.describe PriceAndNameMemoValidator do
  let(:our_acquirable) {create(:membership, :adult)}

  context "when the CartItem's name and price memos accurately reflect the Acquirable's name and price" do

    subject { ValidationSubstrate.new( acquirable: our_acquirable, item_name_memo: our_acquirable.name, item_price_memo: our_acquirable.price_cents ) }

    it 'has a test that is properly set up' do
      expect(subject.item_name_memo).to eql(subject.acquirable.name)
      expect(subject.item_price_memo).to eql(subject.acquirable.price_cents)
    end

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'has no errors' do
      subject.valid?
      expect(subject.errors.size).to eq(0)
    end
  end

  context "when the CartItem's name memo matches the Acquirable's name, but its price memo does not match the acquirable's price" do

    subject { ValidationSubstrate.new( acquirable: our_acquirable, item_name_memo: our_acquirable.name, item_price_memo: our_acquirable.price_cents + 100 ) }

    it 'has a test that is properly set up' do
      expect(subject.item_name_memo).to eql(subject.acquirable.name)
      expect(subject.item_price_memo).not_to eql(subject.acquirable.price_cents)
    end

    it 'is invalid' do
      expect(subject).not_to be_valid
    end

    it 'has one error' do
      subject.valid?
      expect(subject.errors.size).to eq(1)
    end

    it 'has an error on its item_price_memo attribute of the type: :item_price_divergence' do
      subject.valid?
      expect(subject.errors.added?(:item_price_memo, :item_price_divergence)).to eq(true)
    end
  end


  context "when the CartItem's price memo matches the Acquirable's price, but its price memo does not match the acquirable's price" do

    subject { ValidationSubstrate.new( acquirable: our_acquirable, item_name_memo: "Son of " + our_acquirable.name, item_price_memo: our_acquirable.price_cents ) }

    it 'has a test that is properly set up' do
      expect(subject.item_name_memo).not_to eql(subject.acquirable.name)
      expect(subject.item_price_memo).to eql(subject.acquirable.price_cents)
    end

    it 'is invalid' do
      expect(subject).not_to be_valid
    end

    it 'has one error' do
      subject.valid?
      expect(subject.errors.size).to eq(1)
    end

    it 'has an error on its item_name_memo attribute of the type: :item_identity_divergence' do
      subject.valid?
      expect(subject.errors.added?(:item_name_memo, :item_identity_divergence)).to eq(true)
    end
  end

  context "when neither the CartItem's name memo nor its price memo accurately reflect the Acquirable's name or price" do

    subject { ValidationSubstrate.new( acquirable: our_acquirable, item_name_memo: our_acquirable.name + "II: The Acquirening", item_price_memo: our_acquirable.price_cents + 100 ) }

    it 'has a test that is properly set up' do
      expect(subject.item_name_memo).not_to eql(subject.acquirable.name)
      expect(subject.item_price_memo).not_to eql(subject.acquirable.price_cents)
    end

    it 'is invalid' do
      expect(subject).not_to be_valid
    end

    it 'has two errors' do
      subject.valid?
      expect(subject.errors.size).to eq(2)
    end

    it 'has an error on its item_name_memo attribute of the type: :item_identity_divergence' do
      subject.valid?
      expect(subject.errors.added?(:item_name_memo, :item_identity_divergence)).to eq(true)
    end

    it 'has an error on its item_price_memo attribute of the type: :item_price_divergence' do
      subject.valid?
      expect(subject.errors.added?(:item_price_memo, :item_price_divergence)).to eq(true)
    end
  end
end
