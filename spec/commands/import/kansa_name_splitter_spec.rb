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

RSpec.describe Import::KansaNameSplitter do
  subject(:presenter) { described_class.new(name) }

  context "when it's just one name" do
    let(:name) { "McFly" }

    it "assigns to last name only" do
      expect(subject.last_name).to eq "McFly"
      expect(subject.first_name).to be_empty
      expect(subject.title).to be_empty
    end
  end

  context "when there's two names" do
    let(:name) { "Marty McFly" }

    it "assigns first and last name" do
      expect(subject.first_name).to eq "Marty"
      expect(subject.last_name).to eq "McFly"
      expect(subject.title).to be_empty
    end
  end
end
