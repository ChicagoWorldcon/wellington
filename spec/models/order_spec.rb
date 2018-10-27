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
end
