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

RSpec.describe MemberNominationsByCategory do
  let!(:best_graphic_story)    { FactoryBot.create(:category, :best_graphic_story) }
  let!(:best_novel)            { FactoryBot.create(:category, :best_novel) }
  let!(:best_novelette)        { FactoryBot.create(:category, :best_novelette) }
  let!(:best_novella)          { FactoryBot.create(:category, :best_novella) }
  let!(:best_short_story)      { FactoryBot.create(:category, :best_short_story) }
  let!(:john_w_campbell_award) { FactoryBot.create(:category, :john_w_campbell_award) }

  let(:reservation) { create(:reservation) }

  subject(:service) { described_class.new(reservation: reservation) }

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

    let(:best_novel_nominations) { call[best_novel] }

    it "gets keyed by Category" do
      expect(call.keys.last).to be_kind_of(Category)
      expect(call.keys.count).to eq(Category.count)
    end

    it "lists 5 empty nominations per category" do
      expect(best_novel_nominations).to be_kind_of(Array)
      expect(best_novel_nominations.last).to be_kind_of(Nomination)
      expect(best_novel_nominations.count).to be(5)
      expect(best_novel_nominations.map(&:description)).to be_all(&:nil?)
    end

    it "remembers a users past nominations" do
      first_nomination = reservation.nominations.create!(category: best_novel, description: "oh la la")
      second_nomination = reservation.nominations.create!(category: best_novel, description: "oh la la")
      expect(best_novel_nominations.count).to be(5)
      expect(best_novel_nominations.first).to eq first_nomination
      expect(best_novel_nominations.second).to eq second_nomination
      expect(best_novel_nominations.third.description).to be_nil
    end
  end

  describe "#from_params" do
    let(:best_novel_id) { best_novel.id.to_s }

    let(:empty_entry) do
      { "description" => "" }
    end

    let(:filled_entry) do
      { "description" => "The Hobbit" }
    end

    let(:params) do
      ActionController::Parameters.new(
        "reservation"=> {
          "category"=> {
            best_novel_id => {
              "nomination" => {
                "1" => filled_entry,
                "2" => empty_entry,
                "3" => empty_entry,
                "4" => empty_entry,
                "5" => empty_entry,
              },
            },
          },
        },
      )
    end

    it "is chainable" do
      expect(service.from_params(params)).to eq service
    end

    context "after called" do
      before { service.from_params(params) }

      subject(:nominations_by_category) { service.nominations_by_category }

      it { is_expected.to be_kind_of(Hash) }

      let(:best_novel_nominations) { call[best_novel] }

      it "gets keyed by Category" do
        expect(nominations_by_category.keys.last).to be_kind_of(Category)
      end

      it "creates new Nomintions for submitted categories" do
        expect(nominations_by_category[best_novel].first).to be_kind_of(Nomination)
        expect(nominations_by_category[best_novel].first.description).to eq filled_entry["description"]
      end
    end
  end
end
