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

RSpec.describe Money::CreditAccount do
  let!(:adult_membership) { create(:membership, :adult) }
  let!(:reservation) { create(:reservation, :with_claim_from_user, membership: adult_membership) }
  let!(:amount) { Money.new(50_00) }

  subject(:command) { described_class.new(reservation, amount) }

  describe "#call" do
    subject(:call) { command.call }

    it { is_expected.to be_truthy }

    it "creates a charge" do
      expect { call }.to change { Charge.count }.by(1)
      expect(Charge.last.amount).to eq amount
    end
  end
end
