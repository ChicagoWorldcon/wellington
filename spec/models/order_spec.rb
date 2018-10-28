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

require 'rails_helper'

RSpec.describe Order, type: :model do
  subject(:model) { create(:order) }

  it { is_expected.to be_valid }

  describe "#active_on" do
    let(:order_placed_date) { 1.month.ago }
    let(:order_invalidated_date) { order_placed_date + 1.week }
    subject(:model) { create(:order, active_from: order_placed_date, active_to: order_invalidated_date) }

    it "includes order within the boundary" do
      expect(Order.active_at(order_placed_date)).to include(subject)
      expect(Order.active_at(order_invalidated_date)).to include(subject)
    end

    it "excludes order when outside of boundary" do
      expect(Order.active_at(order_placed_date - 1.second)).to_not include(subject)
      expect(Order.active_at(order_invalidated_date + 1.second)).to_not include(subject)
    end
  end

  context "with multiple orders" do
    let(:existing_order) { create(:order) }
    let(:new_purchase) { create(:purchase) }
    let(:another_product) { create(:product, :unwaged) }

    it "lets you create multiple orders of the same product" do
      order = Order.new(purchase: new_purchase, product: existing_order.product)
      expect(order).to be_valid
    end

    context "when against the same purchase" do
      let(:new_order) { Order.new(purchase: existing_order.purchase, product: another_product) }
      let(:transferred_at) { 1.minute.ago }

      it "shows invalid where there are two active orders" do
        expect(existing_order.product.level).to_not eq(another_product.level)
        expect(new_order).to_not be_valid
      end

      it "shows vlaid if one of the two orders is inactive" do
        expect(existing_order.product.level).to_not eq(another_product.level)
        existing_order.update!(active_to: transferred_at)
        new_order.update!(active_from: transferred_at)
        expect(new_order).to be_valid
      end
    end
  end
end
