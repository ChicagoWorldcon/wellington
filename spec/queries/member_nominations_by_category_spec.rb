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
  let(:reservation) { create(:reservation) }

  let!(:best_graphic_story)    { FactoryBot.create(:category, :best_graphic_story) }
  let!(:best_novel)            { FactoryBot.create(:category, :best_novel) }
  let!(:best_novelette)        { FactoryBot.create(:category, :best_novelette) }
  let!(:best_novella)          { FactoryBot.create(:category, :best_novella) }
  let!(:best_short_story)      { FactoryBot.create(:category, :best_short_story) }
  let!(:john_w_campbell_award) { FactoryBot.create(:category, :john_w_campbell_award) }

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

  subject(:service) { described_class.new(reservation: reservation) }

  it { is_expected.to_not be_nil }

  context "when disabled" do
    let(:reservation) { create(:reservation, :disabled) }

    it { is_expected.to_not be_valid }

    it "lists errors" do
      expect { service.valid? }
        .to change { service.errors.messages }
        .to be_present
    end

    it "doesn't build nominations from #from_reservation" do
      expect { service.from_reservation }
        .to_not change { service.nominations_by_category }
        .from(nil)
    end

    it "doesn't build nominations from #from_params" do
      expect { service.from_params(params) }
        .to_not change { service.nominations_by_category }
        .from(nil)
    end
  end

  context "when in instalment" do
    let(:reservation) { create(:reservation, :instalment) }
    it { is_expected.to_not be_valid }
  end

  describe "#from_reservation" do
    it "is chainable" do
      expect(service.from_reservation).to eq service
    end

    it "remembers a users past nominations" do
      first_nomination = reservation.nominations.create!(category: best_novel, description: "oh la la")
      second_nomination = reservation.nominations.create!(category: best_novel, description: "oh la la")
      best_novel_nominations = service.from_reservation.nominations_by_category[best_novel]
      expect(best_novel_nominations.count).to be(5)
      expect(best_novel_nominations.first).to eq first_nomination
      expect(best_novel_nominations.second).to eq second_nomination
      expect(best_novel_nominations.third.description).to be_nil
    end

    context "after called" do
      before do
        service.from_reservation
      end

      describe "#nominations_by_category" do
        subject(:nominations_by_category) { service.nominations_by_category }

        it { is_expected.to be_kind_of(Hash) }

        it "gets keyed by Category" do
          expect(subject.keys.last).to be_kind_of(Category)
          expect(subject.keys.count).to eq(Category.count)
        end

        it "lists 5 empty nominations per category" do
          expect(subject[best_novel]).to be_kind_of(Array)
          expect(subject[best_novel].last).to be_kind_of(Nomination)
          expect(subject[best_novel].count).to be(5)
          expect(subject[best_novel].map(&:description)).to be_all(&:nil?)
        end
      end
    end
  end

  describe "#from_params" do
    it "is chainable" do
      expect(service.from_params(params)).to eq service
    end

    it "updates #nominations_by_category" do
      expect { service.from_params(params) }
        .to change { service.nominations_by_category }
        .to be_present
    end

    context "after called" do
      before { service.from_params(params) }

      describe "#nominations_by_category" do
        subject(:nominations_by_category) { service.nominations_by_category }

        it { is_expected.to be_kind_of(Hash) }

        let(:best_novel_nominations) { subject[best_novel] }

        it "gets keyed by Category" do
          expect(subject.keys.last).to be_kind_of(Category)
        end

        it "creates new Nomintions for submitted categories" do
          expect(subject[best_novel].first).to be_kind_of(Nomination)
          expect(subject[best_novel].first.description).to eq filled_entry["description"]
        end

        describe "#save" do
          let(:params) do
            ActionController::Parameters.new(
              "reservation"=> {
                "category"=> {
                  best_novel_id => {
                    "nomination" => best_novel_nominations
                  }
                }
              }
            )
          end

          context "when there is a single submitted entry" do
            let(:best_novel_nominations) do
              {
                "1" => filled_entry,
                "2" => empty_entry,
              }
            end

            it "creates new Nomination entries" do
              expect { service.save }.to change { Nomination.count }.by(1)
            end
          end

          context "when there are five entries" do
            let(:best_novel_nominations) do
              {
                "1" => filled_entry,
                "2" => filled_entry,
                "3" => filled_entry,
                "4" => filled_entry,
                "5" => filled_entry,
              }
            end

            it "creates new Nomination entries" do
              expect { service.save }.to change { Nomination.count }.by(5)
            end
          end

          context "when entries are submitted taht don't match expected keys" do
            let(:best_novel_nominations) do
              {
                "flub" => filled_entry
              }
            end

            it "doesn't save anything" do
              expect { service.save }.to_not change { Nomination.count }.from(0)
            end
          end
        end
      end
    end
  end
end
