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

RSpec.describe CategoryFormDecorator do
  let(:category) { create(:category) }
  let(:nominations) { create_list(:nomination, 2, category: category) }
  subject(:query) { described_class.new(category, nominations) }

  it { is_expected.to_not be_nil }

  describe "#heading" do
    subject(:heading) { query.heading }

    it { is_expected.to be_kind_of(String) }
    it { is_expected.to include(nominations.count.to_s) }
    it { is_expected.to include(Nomination::VOTES_PER_CATEGORY.to_s) }
    it { is_expected.to include(category.name) }

    context "when there are 0 nominations" do
      let(:nominations) { [] }
      it { is_expected.to include("0 of") }
    end

    context "when some nominations are not persisted" do
      let(:nominations) { build_list(:nomination, 2, category: category) }

      it "doesn't count them towards complete" do
        expect(heading).to include("0 of")
      end
    end
  end

  describe "#accordion_classes" do
    subject(:accordion_classes) { query.accordion_classes }
    it { is_expected.to be "text-dark" }

    context "with no saved nominations" do
      let(:nominations) { build_list(:nomination, 5, category: category) }
      it { is_expected.to be "text-primary" }
    end
  end
end
