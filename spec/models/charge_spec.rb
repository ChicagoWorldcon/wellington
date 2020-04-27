# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
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

RSpec.describe Charge do
  subject(:model) { create(:charge) }
  it { is_expected.to be_valid }

  context "as stripe charge" do
    it "has optional #stripe_id when pending" do
      expect(create(:charge, :pending, stripe_id: nil)).to be_valid
      expect(create(:charge, :pending, stripe_id: "ch_fakestripechargeid")).to be_valid
    end

    it "requires #stripe_id normally" do
      expect(build(:charge, stripe_id: nil)).to_not be_valid
    end
  end
end
