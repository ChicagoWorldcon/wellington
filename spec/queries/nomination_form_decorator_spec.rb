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

RSpec.describe NominationFormDecorator do
  let(:category) { create(:category) }
  let(:nomination) { create(:nomination) }

  subject(:query) { described_class.new(nomination, category) }

  describe "#field_1, #field_2 and #field_3" do
    it "delegates to nomination" do
      expect(query.field_1).to eq nomination.field_1
      expect(query.field_2).to eq nomination.field_2
      expect(query.field_3).to eq nomination.field_3
    end
  end

  describe "#column_classes" do
    Test = Struct.new(:category, :expected_column_classes)

    [
      Test.new(
        FactoryBot.create(:category, :best_novel),
        "col-12 col-md-4",
      ),
      Test.new(
        FactoryBot.create(:category, :best_professional_artist),
        "col-12 col-md-6",
      ),
      Test.new(
        FactoryBot.create(:category, :best_semiprozine),
        "col-12",
      ),
    ].each.with_index(1) do |test, n|
      it "has expected classes for case #{n}" do
        query = described_class.new(nomination, test.category)
        expect(query.column_classes).to eq(test.expected_column_classes)
      end
    end
  end
end
