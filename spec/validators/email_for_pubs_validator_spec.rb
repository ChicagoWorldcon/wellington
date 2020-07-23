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

class ValidationBait
  include ActiveModel::Model
  include ActiveModel::Validations
  attr_accessor :email, :publication_format
  validates_with EmailForPubsValidator, fields: [:email, :publication_format]
end

RSpec.describe EmailForPubsValidator do

  context 'when email address is not provided' do
    context 'when no publications are requested' do
      subject { ValidationBait.new(email: "", publication_format: ChicagoContact::PAPERPUBS_NONE ) }
      it 'is valid and has no errors' do
        expect(subject).to be_valid
      end
      it 'had no errors' do
        subject.valid?
        expect(subject.errors.size).to eq(0)
      end
    end

    context 'when only print publications are requested' do
      subject { ValidationBait.new(email: "", publication_format: ChicagoContact::PAPERPUBS_MAIL) }
      it 'is valid' do
        expect(subject).to be_valid
      end
      it 'had no errors' do
        subject.valid?
        expect(subject.errors.size).to eq(0)
      end
    end

    context 'when email and print publications are requested' do
      subject {ValidationBait.new(email: "", publication_format: ChicagoContact::PAPERPUBS_BOTH )}
      it 'is invaid' do
        expect(subject).to_not be_valid
      end

      it 'has errors on email and publication_format' do
        subject.valid?
        expect(subject.errors.size).to eq(2)
        expect(subject.errors[:email].size).to eq(1)
        expect(subject.errors[:publication_format].size).to eq(1)
      end
    end

    context 'when only email publications are requested' do
      subject { ValidationBait.new(email: "", publication_format: ChicagoContact::PAPERPUBS_ELECTRONIC) }
      it 'is invalid' do
        expect(subject).to_not be_valid
      end
      it 'has errors on email and publication_format' do
        subject.valid?
        expect(subject.errors.size).to eq(2)
        expect(subject.errors[:email].size).to eq(1)
        expect(subject.errors[:publication_format].size).to eq(1)
      end
    end
  end

  context 'when an email address is provided' do
    context 'when no publications are requested' do
      subject { ValidationBait.new(email: "valid@validsoft.va", publication_format: ChicagoContact::PAPERPUBS_NONE ) }
      it 'is valid' do
        expect(subject).to be_valid
      end
      it 'has no errors' do
        subject.valid?
        expect(subject.errors.size).to eq(0)
      end
    end

    context 'when only print publications are requested' do
      subject { ValidationBait.new(email: "valid@validsoft.va", publication_format: ChicagoContact::PAPERPUBS_MAIL ) }
      it 'is valid' do
        expect(subject).to be_valid
      end
      it 'has no errors' do
        subject.valid?
        expect(subject.errors.size).to eq(0)
      end
    end

    context 'when email and print publications are requested' do
      subject { ValidationBait.new(email: "valid@validsoft.va", publication_format: ChicagoContact::PAPERPUBS_BOTH ) }
      it 'is valid' do
        expect(subject).to be_valid
      end
      it 'has no errors' do
        subject.valid?
        expect(subject.errors.size).to eq(0)
      end
    end

    context 'when only email publications are requested' do
      subject { ValidationBait.new(email: "valid@validsoft.va", publication_format: ChicagoContact::PAPERPUBS_ELECTRONIC ) }
      it 'is valid' do
        expect(subject).to be_valid
      end
      it 'has no errors' do
        subject.valid?
        expect(subject.errors.size).to eq(0)
      end
    end
  end
end
