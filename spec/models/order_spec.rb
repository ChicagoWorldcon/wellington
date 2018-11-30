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

RSpec.describe Order, type: :model do
  subject(:model) { create(:order, :with_purchase, :with_membership) }

  it { is_expected.to be_valid }

  describe "#active_at" do
    let(:order_placed_at) { 1.month.ago }
    let(:order_upgraded_at) { order_placed_at + 1.week }
    let!(:closed_order) do
      create(:order, :with_purchase, :with_membership, active_from: order_placed_at, active_to: order_upgraded_at)
    end

    subject(:scope) { Order.active_at(time) }

    context "just before order was placed" do
      let(:time) { order_placed_at - 1.second }
      it { is_expected.to_not include(closed_order) }
    end

    context "at the time the order was placed" do
      let(:time) { order_placed_at }
      it { is_expected.to include(closed_order) }
    end

    context "just before the order was upgraded" do
      let(:time) { order_upgraded_at - 1.second }
      it { is_expected.to include(closed_order) }
    end

    context "at the time the order was upgraded" do
      let(:time) { order_upgraded_at }
      it { is_expected.to_not include(closed_order) }
    end
  end

  context "with multiple orders" do
    let(:existing_order) { create(:order, :with_purchase, :with_membership) }
    let(:new_purchase) { create(:purchase) }
    let(:another_membership) { create(:membership, :unwaged) }

    it "lets you create multiple orders of the same membership" do
      order = Order.new(purchase: new_purchase, membership: existing_order.membership)
      expect(order).to be_valid
    end

    context "when against the same purchase" do
      let(:new_order) { Order.new(purchase: existing_order.purchase, membership: another_membership) }
      let(:upgraded_at) { 1.minute.ago }

      it "shows invalid where there are two active orders" do
        expect(existing_order.membership.name).to_not eq(another_membership.name)
        expect(new_order).to_not be_valid
      end

      it "shows vlaid if one of the two orders is inactive" do
        expect(existing_order.membership.name).to_not eq(another_membership.name)
        existing_order.update!(active_to: upgraded_at)
        new_order.active_from = upgraded_at
        expect(new_order).to be_valid
      end
    end
  end
end
