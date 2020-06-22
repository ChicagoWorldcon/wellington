# frozen_string_literal: true

# Copyright 2019 AJ Esler
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

RSpec.describe PaymentAmountOptions, type: :model do
  let(:amount_owed) { Money.new(225_00) }
  subject(:amounts) { described_class.new(amount_owed).amounts }

  it "has the expected steps for a new set of payments" do
    is_expected.to eq([Money.new(75_00), Money.new(125_00), Money.new(175_00), Money.new(225_00)])
  end

  context "when the amount owed is less than the minimum payment" do
    let(:amount_owed) { Money.new(32_00) }

    it { is_expected.to eq [amount_owed] }
  end

  context "when the amount owed is greater than the minimum payment" do
    let(:amount_owed) { Money.new(1930_00) }

    it("offers a series of payment amounts") do
      is_expected.to include(PaymentAmountOptions::MIN_PAYMENT)
      is_expected.to include(PaymentAmountOptions::MIN_PAYMENT + PaymentAmountOptions::PAYMENT_STEP)
      is_expected.to include(amount_owed)
    end
  end
end
