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

RSpec.describe NominationsController, type: :controller do
  render_views

  let(:reservation) { create(:reservation, :with_order_against_membership, :with_claim_from_user) }
  let(:user) { reservation.user }

  describe "#index" do
    subject(:get_index) do
      get :index, params: {reservation_id: reservation.id }
    end

    it "404s when signed out" do
      expect { get_index }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "404s when you dnn't have nomination rights" do
      reservation.membership.update!(can_nominate: false)
      expect { get_index }.to raise_error(ActiveRecord::RecordNotFound)
    end

    context "when signed in" do
      before { sign_in(user) }

      # from config/initializers/hugo.rb
      after do
        $nomination_opens_at = time_from("HUGO_NOMINATIONS_OPEN_AT") || Time.now
        $voting_opens_at = time_from("HUGO_VOTING_OPEN_AT") || 1.day.from_now
        $hugo_closed_at = time_from("HUGO_CLOSED_AT") || 2.weeks.from_now
      end

      it "renders during nominatino" do
        $nomination_opens_at = 1.second.ago
        $voting_opens_at = 1.day.from_now
        $hugo_closed_at = 2.days.from_now
        expect(get_index).to have_http_status(:ok)
      end

      it "doesn't render before nomination" do
        $nomination_opens_at = 1.day.from_now
        $voting_opens_at = 2.days.from_now
        $hugo_closed_at = 3.days.from_now
        expect { get_index }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "deosn't renderafter nomination" do
        $nomination_opens_at = 1.day.ago
        $voting_opens_at = 1.second.ago
        $hugo_closed_at = 1.day.from_now
        expect { get_index }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "#show" do
    before { sign_in user }

    let(:hugo) { create(:election) }
    let(:best_novel) { create(:category, :best_novel, election: hugo) }

    let(:retro_hugo) { create(:election, :retro) }
    let(:retro_best_novel) { create(:category, :retro_best_novel, election: retro_hugo) }

    context "for hugo" do
      subject(:get_show) do
        get :show, params: { id: hugo.i18n_key, reservation_id: reservation.id }
      end

      it { is_expected.to have_http_status(:ok) }

      it "doesn't render retro content" do
        get_show
        expect(response.body).to_not include(retro_best_novel.name)
      end
    end
  end

  describe "#update" do
    before { sign_in user }

    let!(:best_novel) { create(:category, :best_novel) }
    let!(:best_series) { create(:category, :best_series) }

    let(:filled_entry) do
      {
        field_1: "Leviathan Wakes",
        field_2: "James S. A. Corey",
        field_3: "Orbit Books",
      }
    end

    let(:partial_entry) do
      {
        field_1: "This Side of Paradise",
        field_2: "Ummm...",
        field_3: "",
      }
    end

    let(:empty_entry) do
      {
        field_1: "",
        field_2: "",
        field_3: "",
      }
    end

    context "when posting valid params" do
      subject(:post_create) do
        post(:create, params: {
          reservation_id: reservation.id,
          category_id: best_novel.id,
          category: {
            best_novel.id => {
              nomination: {
                1 => filled_entry,
                2 => partial_entry,
                3 => empty_entry,
                4 => empty_entry,
                5 => empty_entry,
              }
            }
          },
        })
      end

      it "renders ok" do
        expect(post_create).to have_http_status(:ok)
      end

      it "creates nominations" do
        expect { post_create }.to change { Nomination.count }.from(0)
      end
    end
  end
end
