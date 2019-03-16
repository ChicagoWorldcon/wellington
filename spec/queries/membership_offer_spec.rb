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

RSpec.describe MembershipOffer do
  subject(:model) { described_class.new(membership) }
  let!(:membership) { create(:membership, :adult) }

  it { is_expected.to_not be_nil }

  describe "#to_s" do
    subject(:to_s) { model.to_s }
    it { is_expected.to match(/adult/i) }
    it { is_expected.to match(/\$\d+\.\d+/) }
    it { is_expected.to match(/NZD/) }

    context "when membership is free" do
      let(:membership) { create(:membership, :kid_in_tow) }
      it { is_expected.to match(/free/i) }
    end
  end

  describe "#self.options" do
    subject(:options) { MembershipOffer.options }
    it { is_expected.to_not be_empty }
  end
end
