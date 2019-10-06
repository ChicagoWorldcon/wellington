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

RSpec.describe ListNominations do
  let!(:category_best_editor_long_form)    { FactoryBot.create(:category, :best_editor_long_form) }
  let!(:category_best_editor_short_form)   { FactoryBot.create(:category, :best_editor_short_form) }
  let!(:category_best_graphic_story)       { FactoryBot.create(:category, :best_graphic_story) }
  let!(:category_best_novel)               { FactoryBot.create(:category, :best_novel) }
  let!(:category_best_novelette)           { FactoryBot.create(:category, :best_novelette) }
  let!(:category_best_novella)             { FactoryBot.create(:category, :best_novella) }
  let!(:category_best_professional_artist) { FactoryBot.create(:category, :best_professional_artist) }
  let!(:category_best_related_work)        { FactoryBot.create(:category, :best_related_work) }
  let!(:category_best_semiprozine)         { FactoryBot.create(:category, :best_semiprozine) }
  let!(:category_best_short_story)         { FactoryBot.create(:category, :best_short_story) }
  let!(:category_john_w_campbell_award)    { FactoryBot.create(:category, :john_w_campbell_award) }

  let(:reservation) { create(:reservation) }

  subject(:service) { described_class.new(reservation) }

  it { is_expected.to_not be_nil }

  context "when disabled" do
    let(:reservation) { create(:reservation, :disabled) }

    it "won't list nominations" do
      expect(service.call).to be_falsey
      expect(service.errors).to_not be_empty
    end
  end

  context "when in instalment" do
    let(:reservation) { create(:reservation, :instalment) }

    it "won't list nominations" do
      expect(service.call).to be_falsey
      expect(service.errors).to_not be_empty
    end
  end

  context "#call" do
    subject(:call) { service.call }

    it { is_expected.to be_kind_of(Hash) }

    it "gets keyed by Category" do
      expect(call.keys.last).to be_kind_of(Category)
      expect(call.keys.count).to eq(Category.count)
    end
  end
end
