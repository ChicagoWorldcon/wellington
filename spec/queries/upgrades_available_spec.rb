# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
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

RSpec.describe Grant, type: :model do
  subject(:query) { UpgradesAvailable.new(from: from) }

  context "when adult" do
    let(:from) { :adult }

    it { is_expected.to_not be_nil }

    it "doesn't have upgrade options" do
      expect(query.call).to be_empty
    end
  end
end
