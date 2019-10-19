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

  let!(:best_novel)       { FactoryBot.create(:category, :best_novel) }
  let!(:retro_best_novel) { FactoryBot.create(:category, :retro_best_novel) }
  let!(:best_novelette)   { FactoryBot.create(:category, :best_novelette) }
  let!(:best_novella)     { FactoryBot.create(:category, :best_novella) }
  let!(:best_short_story) { FactoryBot.create(:category, :best_short_story) }

  let(:best_novel_id) { best_novel.id.to_s }

  let(:empty_entry) do
    { "field_1" => "" }
  end

  let(:filled_entry) do
    {
      "field_1" => "The Hobbit",
      "field_2" => "J. R. R. Tolkien",
      "field_3" => "George Allen & Unwin",
    }
  end

  let(:params) do
    ActionController::Parameters.new(
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
      first_nomination = reservation.nominations.create!(category: best_novel, field_1: "oh la la")
      second_nomination = reservation.nominations.create!(category: best_novel, field_1: "oh la la")
      best_novel_nominations = service.from_reservation.nominations_by_category[best_novel]
      expect(best_novel_nominations.count).to be(5)
      expect(best_novel_nominations.first).to eq first_nomination
      expect(best_novel_nominations.second).to eq second_nomination
      expect(best_novel_nominations.third.field_1).to be_nil
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
          expect(subject[best_novel].map(&:field_1)).to be_all(&:nil?)
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

    it "loads entries from other categories" do
      reservation.nominations.create!(
        category: best_short_story,
        field_1: "The Office of Missing Persons",
        field_2: "Akil Kumaraswamy",
        field_3: "Lit Hub",
      )
      service.from_params(params)
      short_story_nominations = service.nominations_by_category[best_short_story]
      expect(short_story_nominations.first.field_1).to eq "The Office of Missing Persons"
    end

    context "when there are 5 entries submitted and there were 5 entries saved" do
      let!(:previous_nominations) do
        5.times.map do
          create(:nomination, reservation: reservation, category: best_novel)
        end
      end

      let(:params) do
        ActionController::Parameters.new(
          "category"=> {
            best_novel_id => {
              "nomination" => {
                "1" => filled_entry,
                "2" => filled_entry,
                "3" => filled_entry,
                "4" => filled_entry,
                "5" => filled_entry,
              },
            },
          },
        )
      end

      before do
        service.from_params(params)
      end

      it "succeeds when calling #save" do
        expect(service.save).to be_truthy
      end

      it "doesn't #save than 5 entries per category" do
        expect { service.save }.to_not change { Nomination.count }.from(5)
      end

      it "replaces entries on #save" do
        service.from_params(params)
        expect { service.save }.to change { best_novel.reload.nominations.first }
      end
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
          expect(subject[best_novel].first.field_1).to eq filled_entry["field_1"]
        end

        it "has 5 per category" do
          subject.each do |category, nominations|
            expect(nominations.count).to eq 5
          end
        end
      end

      describe "#save" do
        let(:params) do
          ActionController::Parameters.new(
            "category"=> {
              best_novel_id => {
                "nomination" => best_novel_nominations
              },
            },
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

        context "when entries are submitted that don't match expected keys" do
          let(:best_novel_nominations) do
            { "flub" => filled_entry }
          end

          it "doesn't save anything" do
            expect { service.save }.to_not change { Nomination.count }.from(0)
          end
        end

        context "with empty form" do
          let(:best_novel_nominations) { {} }

          it "resets all nominations in that category" do
            reservation.nominations.create!(category: best_novel, field_1: "oh la la")
            expect { service.save }
              .to change { best_novel.nominations.count }
              .by(-1)
          end

          it "doesn't reset other categories" do
            reservation.nominations.create!(category: best_novelette, field_1: "oh la la")
            expect { service.save } .to_not change { best_novelette.nominations.count }
          end
        end
      end
    end
  end
end
