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

RSpec.describe SiteSelection, type: :model do
  subject(:model) { create(:site_selection) }
  it { is_expected.to be_valid }

  describe "#token" do
    it "requires token" do
      expect(build(:site_selection, token: nil)).to_not be_valid
    end

    it "becomes invalid if one digit is off" do
      expect(build(:site_selection, token: "4403-5113-0198")).to be_valid
      expect(build(:site_selection, token: "4403-5113-0199")).to_not be_valid
    end

    it "forces you to put hyphens in the right place" do
      expect(build(:site_selection, token: "4403-5113-0198")).to be_valid
      expect(build(:site_selection, token: "4403-511-30198")).to_not be_valid
      expect(build(:site_selection, token: "44035-113-0198")).to_not be_valid
    end

    it "enforces token uniqueness" do
      expect(subject).to be_valid
      clone = subject.dup
      expect(clone).to_not be_valid
      expect(clone.errors.full_messages).to include("Token has already been taken")
    end
  end
end
