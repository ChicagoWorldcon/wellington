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

RSpec.describe PaymentAmountOptions, type: :model do
  subject(:amounts) { described_class.new(amount_owed).amounts }

  context "when the amount owed is less than the minimum payment" do
    let(:amount_owed) { 3200 }

    it { is_expected.to eq [amount_owed] }
  end

  context "when the amount owed is greater than the minimum payment" do
    let(:amount_owed) { 11300 }

    it("offers a series of payment amounts") { is_expected.to eq [4000, 8000, amount_owed] }
  end
end
