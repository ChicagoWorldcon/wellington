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

RSpec.describe HugoState do
  subject(:query) { described_class.new }

  # Reset times
  around do |test|
    original_values = $nomination_opens_at, $voting_opens_at, $hugo_closed_at
    $nomination_opens_at, $voting_opens_at, $hugo_closed_at = nil, nil, nil
    test.run
    $nomination_opens_at, $voting_opens_at, $hugo_closed_at = original_values
  end

  context "before nominations open" do
    before do
      $nomination_opens_at = 1.day.from_now
      $voting_opens_at = 2.days.from_now
      $hugo_closed_at = 3.days.from_now
    end

    it { is_expected.to_not have_nominations_opened }
    it { is_expected.to_not have_voting_opened }
  end

  context "after nominations open" do
    before do
      $nomination_opens_at = Time.now
      $voting_opens_at = 1.day.from_now
      $hugo_closed_at = 2.days.from_now
    end

    it { is_expected.to have_nominations_opened }
    it { is_expected.to_not have_voting_opened }
  end

  context "after voting is open" do
    before do
      $nomination_opens_at = 1.day.ago
      $voting_opens_at = Time.now
      $hugo_closed_at = 1.day.from_now
    end

    it { is_expected.to_not have_nominations_opened }
    it { is_expected.to have_voting_opened }
  end

  context "when voting is closed" do
    before do
      $nomination_opens_at = 2.days.ago
      $voting_opens_at = 1.day.ago
      $hugo_closed_at = Time.now
    end

    it { is_expected.to_not have_nominations_opened }
    it { is_expected.to_not have_voting_opened }
  end
end
