# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2020 Victoria Garcia
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

  describe "#hash" do
    subject(:hash) { model.hash }

    let!(:membership) { create(:membership, :adult) }

    it { is_expected.to match(/adult/i) }
    it { is_expected.to match(/\d+/) }
    it { is_expected.to include($currency) }

    context "when membership is free" do
      let(:membership) { create(:membership, :kid_in_tow) }
      it { is_expected.to match(/free/i) }
    end
  end

  describe "#self.options" do
    before do
      create(:membership, :kid_in_tow)
      create(:membership, :young_adult)
      create(:membership, :adult)
    end

    subject(:options) { MembershipOffer.options }

    it { is_expected.to_not be_empty }

    it "orders by price" do
      expect(subject.first.to_s).to match(/adult/i)
      expect(subject.last.to_s).to match(/kid/i)
    end
  end

  describe "#dob_required?" do
    subject(:dob_required?) { model.dob_required? }

    let(:membership) { create(:membership, :adult) }
    it { is_expected.to equal false }

    context "for child" do
      let(:membership) { create(:membership, :child) }
      it { is_expected.to equal true}
    end
  end

end
