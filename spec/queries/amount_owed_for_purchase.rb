# frozen_string_literal: true

# Copyright 2019 AJ Esler
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

RSpec.describe AmountOwedForPurchase do

  subject(:query) { AmountOwedForPurchase.new(purchase) }

  describe "#amount_owed" do
    subject(:amount_owed) { query.amount_owed }

    context "with no charges" do
      let(:purchase) { create(:purchase, :with_order_against_membership) }
      let(:membership) { purchase.membership }

      it { is_expected.to eq membership.price }
    end

    context "with some charges" do
      let(:user) { create(:user) }
      let(:claim) { create(:claim, :with_purchase, user: user) }
      let(:membership) { claim.purchase.membership }
      let(:charge_amount) { 1000 }
      let(:purchase) { claim.purchase }

      before do
        charge = create(:charge, user: user, purchase: claim.purchase, amount: charge_amount)
      end

      it "returns the amount owing" do
        expect(amount_owed).to eq (membership.price - charge_amount)
      end
    end
  end
end
