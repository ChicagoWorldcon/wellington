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

RSpec.describe PlanCredit do
  context "with bad user input" do
    [
      described_class.new,
      described_class.new(amount_cents: 0),
      described_class.new(amount_cents: -1),
      described_class.new(amount_cents: "flubber"),
    ].each.with_index(1) do |model, i|
      it "is invalid in case #{i}" do
        expect(model).to_not be_valid
      end
    end
  end

  context "with good user input" do
    [
      described_class.new(amount_cents: 1),
      described_class.new(amount_cents: 10),
      described_class.new(amount_cents: 100),
      described_class.new(amount_cents: 1000),
    ].each.with_index(1) do |model, i|
      it "is valid in case #{i}" do
        expect(model).to be_valid
      end
    end
  end
end
