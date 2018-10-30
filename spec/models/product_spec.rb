# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
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

RSpec.describe Product, type: :model do
  subject(:model) { create(:product, :adult, :with_order_for_purchase) }

  it { is_expected.to be_valid }

  describe "#active_purchases" do
    it "can access purchases directly" do
      expect(model.purchases.count).to be(1)
    end

    it "doesn't list purchases that become inactive" do
      model.orders.update_all(active_to: 1.minute.ago)
      expect(model.purchases.count).to be(0)
    end
  end

  describe "#active_at" do
    let(:product_available_at) { 1.month.ago }
    let(:product_inactive_from) { product_available_at + 1.week }
    let!(:our_product) { create(:product, :adult, active_from: product_available_at, active_to: product_inactive_from) }

    subject(:scope) { Product.active_at(time) }

    context "just before product is available" do
      let(:time) { product_available_at - 1.second }
      it { is_expected.to_not include(our_product) }
    end

    context "as the product becomes available" do
      let(:time) { product_available_at }
      it { is_expected.to include(our_product) }
    end

    context "just before product becomes inactive" do
      let(:time) { product_inactive_from - 1.second }
      it { is_expected.to include(our_product) }
    end

    context "as the product becomes inactive" do
      let(:time) { product_inactive_from }
      it { is_expected.to_not include(our_product) }
    end
  end
end
