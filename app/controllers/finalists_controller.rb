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

class FinalistsController < ApplicationController
  def show
    respond_to do |format|
      format.html # show.html
      format.json {
        render json: {
          categories: sample_ranked_categories
        }
      }
    end
  end

  private

  # TODO Enforce voting is open
  # TODO Privacy, users can only see this if they hold the reservation
  def sample_ranked_categories
    sample_reservation = Membership.can_vote.first.reservations.sample
    categories_in_election = Category.joins(:election).where(elections: { i18n_key: params[:id] })
    position_by_finalist = sample_reservation.ranks.pluck(:finalist_id, :position).to_h

    categories_in_election.includes(:finalists).order("categories.order").map do |c|
      finalists = c.finalists.map { |f| TransformFinalist.new(f, position_by_finalist).call }
      TransformCategory.new(c, finalists).call
    end
  end

  TransformCategory = Struct.new(:category, :finalists) do
    def call
      {
        id: category.id,
        name: category.name,
        finalists: finalists,
      }

    end
  end

  TransformFinalist = Struct.new(:finalist, :position_by_finalist) do
    def call
      {
        id: finalist.id,
        name: finalist.description,
        rank: position_by_finalist[finalist.id],
      }
    end
  end
end
