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

RSpec.describe Transfer, type: :model do
  subject(:model) { create(:transfer) }
  it { is_expected.to be_valid }

  context "when there's already a transfer on the purchase" do
    let(:purchase) { create(:purchase) }
    it "sets the second to invalid" do
      expect(create(:transfer, purchase: purchase)).to be_valid
      expect(build(:transfer, purchase: purchase)).to_not be_valid
    end
  end
end
