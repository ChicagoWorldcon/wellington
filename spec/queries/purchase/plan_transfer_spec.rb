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

RSpec.describe Purchase::PlanTransfer do
  let(:purchase)      { create(:purchase, :with_claim_from_user, :with_order_against_membership) }
  let(:email_address) { Faker::Internet.email }
  subject(:query)     { described_class.new(purchase_id: purchase.id, new_owner: email_address) }

  it { is_expected.to be_valid }

  it "isn't valid without a purchase id" do
    expect(described_class.new(new_owner: email_address)).to_not be_valid
  end

  it "needs a valid email address" do
    expect(described_class.new(purchase_id: purchase.id)).to_not be_valid
    expect(described_class.new(purchase_id: purchase.id, new_owner: "silly")).to_not be_valid
  end

  describe "#purchase" do
    it "raises exception when it can't find the purchase" do
      query = described_class.new(new_owner: email_address, purchase_id: 42)
      expect { query.purchase }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "finds the corrosponding purchase model" do
      expect(query.purchase).to eq purchase
    end
  end

  describe "#from_user" do
    subject(:from_user) { query.from_user }
    it { is_expected.to_not be_nil }
  end

  describe "#to_user" do
    subject(:to_user) { query.to_user }

    it "creates users when they're not present" do
      query # forcs all the setup of the class
      expect { to_user }.to change { User.count }.by(1)
    end

    it "doesn't create users if they're present" do
      query # forcs all the setup of the class
      User.create!(email: email_address)
      expect { to_user }.to_not change { User.count }
    end
  end
end
