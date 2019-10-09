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

  let(:user) { create(:user) }
  let(:reservation) { create(:reservation, :with_order_against_membership, user: user) }

  describe "#index" do
    subject(:get_index) do
      get :index, params: {reservation_id: reservation.id }
    end

    it "404s when signed out" do
      expect { get_index }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "renders ok when signed in" do
      sign_in user
      get_index
      expect(response).to have_http_status(:ok)
    end
  end

  xdescribe "#create" do
    before { sign_in user }

    let!(:best_novel) { FactoryBot.create(:category, :best_novel) }
    let!(:best_novel_id) { best_novel.id.to_s }

    let(:empty_entry) do
      { "description" => "" }
    end

    let(:filled_entry) do
      { "description" => "The Hobbit" }
    end

    it "renders when submitting good entries" do
      post :create, params: {
        reservation_id: reservation.id,
        "reservation"=> {
          "category"=> {
            best_novel_id => {
              "nomination" => {
                "1" => filled_entry,
              },
            },
          },
        },
      }

      expect(response).to have_http_status(:ok)
    end
  end
end
