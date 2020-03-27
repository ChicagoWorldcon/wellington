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

RSpec.describe Rank, type: :model do
  let(:tom) { create(:reservation) }
  let(:jerry) { create(:reservation) }
  subject(:model) { create(:rank, reservation: tom) }

  it { is_expected.to be_valid }

  it "is invalid without position" do
    expect(build(:rank, position: nil)).to_not be_valid
  end

  it "won't let you reuse positions" do
    expect(model).to be_valid
    model_2 = build(:rank, position: model.position)
    expect(model_2).to_not be_valid
  end

  xit "lets you reuse positions from different reservations" do
    expect(create(:rank, position: 1, reservation: tom)).to be_valid
    expect(build(:rank, position: 1, reservation: jerry)).to be_valid
  end
end
