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

RSpec.describe SetHugoGlobals do
  around do |test|
    original_values = $nomination_opens_at, $voting_opens_at, $hugo_closed_at
    $nomination_opens_at, $voting_opens_at, $hugo_closed_at = nil, nil, nil
    test.run
    $nomination_opens_at, $voting_opens_at, $hugo_closed_at = original_values
  end

  describe "#call" do
    subject(:call) { described_class.new.call }

    it "changes nomination_opens_at from nil" do
      expect { call }.to change { $nomination_opens_at }.from(nil)
    end

    it "changes voting_opens_at from nil" do
      expect { call }.to change { $voting_opens_at }.from(nil)
    end

    it "changes hugo_closed_at from nil" do
      expect { call }.to change { $hugo_closed_at }.from(nil)
    end
  end
end
