# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
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

RSpec.describe Reservation, type: :model do
  context "when adult" do
    subject(:model) { create(:reservation) }
    it { is_expected.to be_valid }
    it { is_expected.to be_transferable }

    it "enforces uniqueness on membership number" do
      duplicate_membership = build(:reservation, membership_number: subject.membership_number)
      expect(duplicate_membership).to_not be_valid
    end
  end

  context "with order" do
    subject(:model) { create(:reservation, :with_order_against_membership) }

    it "has access to the active order" do
      expect(model.orders.active.count).to eq 1
      expect(model.active_order).to eq model.orders.active.first
    end

    it "has access to reservation through active orders" do
      expect(model.membership).to eq model.orders.active.first.membership
    end
  end

  context "with claim" do
    subject(:model) { create(:reservation, :with_claim_from_user) }

    it "has access ot the active claim" do
      expect(model.claims.active.count).to eq 1
      expect(model.active_claim).to eq model.claims.active.first
    end

    it "has access to user through active claims" do
      expect(model.user).to eq model.claims.active.first.user
    end
  end

  describe "#transferable?" do
    [Reservation::INSTALMENT, Reservation::PAID].each do |state|
      it "is true when #{state}" do
        expect(build(:reservation, state: state)).to be_transferable
      end
    end

    [Reservation::DISABLED].each do |state|
      it "is false when #{state}" do
        expect(build(:reservation, state: state)).to_not be_transferable
      end
    end
  end
end
