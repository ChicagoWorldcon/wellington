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
  let(:tolkien) { create(:finalist, description: "Tolkien") }

  subject(:model) { create(:rank, reservation: tom) }

  it { is_expected.to be_valid }

  it "is invalid without position" do
    expect(build(:rank, position: nil)).to_not be_valid
  end

  it "won't let you reuse positions on same reservation" do
    expect(model).to be_valid
    expect(model.dup).to_not be_valid
  end

  it "lets you reuse positions from different reservations" do
    expect(create(:rank, position: 1, reservation: tom)).to be_valid
    expect(build(:rank, position: 1, reservation: jerry)).to be_valid
  end

  it "lets you reuse positions across categories" do
    best_novel = create(:category, :best_novel)
    best_editor = create(:category, :best_editor_short_form)

    novel_finalist = create(:finalist, category: best_novel)
    editor_finalist = create(:finalist, category: best_editor)

    expect(create(:rank, reservation: tom, position: 1, finalist: novel_finalist)).to be_valid
    expect(build(:rank, reservation: tom, position: 1, finalist: editor_finalist)).to be_valid
  end

  it "won't let you rank the same finalist twice" do
    rank_1 = create(:rank, position: 1, reservation: tom, finalist: tolkien)
    rank_2 = build(:rank, position: 2, reservation: tom, finalist: tolkien)
    expect(rank_1).to be_valid
    expect(rank_2).to_not be_valid
  end

  it "will let you rank the same finalist over different reservations" do
    rank_1 = create(:rank, position: 1, reservation: tom, finalist: tolkien)
    rank_2 = build(:rank, position: 2, reservation: jerry, finalist: tolkien)
    expect(rank_1).to be_valid
    expect(rank_2).to be_valid
  end
end
