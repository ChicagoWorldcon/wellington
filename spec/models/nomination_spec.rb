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

RSpec.describe Nomination, type: :model do
  subject(:nomination) { create(:nomination) }

  it "generates a valid model" do
    expect(nomination).to be_valid
  end

  [
    {field_1: "1", field_2: nil, field_3: nil},
    {field_1: nil, field_2: "2", field_3: nil},
    {field_1: nil, field_2: nil, field_3: "3"},
  ].each.with_index(1) do |valid_params, n|
    it "is valid when submited with case #{n}" do
      expect(build(:nomination, **valid_params)).to be_valid
    end
  end

  it "isn't valid when no fields are set" do
    invalid_model = build(:nomination, field_1: nil, field_2: nil, field_3: nil)
    expect(invalid_model).to_not be_valid
  end

  describe "#to_s" do
    it "represents 3 fields when all are presnt" do
      model = build(:nomination, field_1: "one", field_2: "two", field_3: "three")
      expect(model.to_s).to eq "one; two; three"
    end

    context "when blank entries and 1 field present" do
      [
        {field_1: "1", field_2: nil, field_3: nil},
        {field_1: nil, field_2: "2", field_3: nil},
        {field_1: nil, field_2: nil, field_3: "3"},
        {field_1: "1", field_2: "", field_3: ""},
        {field_1: "", field_2: "2", field_3: ""},
        {field_1: "", field_2: "", field_3: "3"},
      ].each.with_index(1) do |valid_params, n|
        it "doesn't include ';' for case #{n}" do
          model = build(:nomination, **valid_params)
          expect(model.to_s).to_not include(";")
        end
      end
    end
  end
end
