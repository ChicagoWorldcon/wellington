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

RSpec.describe User, type: :model do
  subject(:user) { create(:user, :with_purchase) }

  it { is_expected.to be_valid }

  # I felt the need to do this because factory code gets quite hairy, especially with factories calling factories from
  # the :with_purchase trait.
  describe "user factory links" do
    it "should be able to access purchase directly" do
      expect(user.purchases).to include user.claims.active.first.purchase
    end

    it "should have a charge equal to the price of the membership" do
      expect(user.charges.first.cost).to eq user.purchases.first.membership.price
    end
  end
end
