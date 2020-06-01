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
  before_action :lookup_reservation!
  before_action :check_access!
  before_action do
    lookup_election!(params[:id])
  done
  # before_action :lookup_legal_name_or_redirect

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

  def update
    builder = MemberVotingByCategory.new(categories: ordered_categories_for_election, reservation: @reservation)
    builder.from_params(params)
    builder.save

    if hugo_admin_signed_in?
      @reservation.user.notes.create!(
        content: %{
          Voting form updated by hugo admin #{current_support.email}
          on behalf of member ##{@reservation.membership_number}
        }.strip_heredoc
      )
    end

    @category = Category.find(params[:category_id])
    @nominations_by_category = builder.nominations_by_category

    if request.xhr?
      category_decorator = CategoryFormDecorator.new(@category, @nominations_by_category[@category])
      render json: {
        updated_heading: category_decorator.heading,
        updated_classes: category_decorator.accordion_classes,
      }
      return
    end

    # Render happens if someone hits the "submit all" button
    render "nominations/show"
  end

  private

  def sample_ranked_categories
    categories_in_election = Category.joins(:election).where(elections: { i18n_key: params[:id] })
    position_by_finalist = @reservation.ranks.pluck(:finalist_id, :position).to_h

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

  def check_access!
    # You have unrestricted access if you're a hugo admin
    return true if hugo_admin_signed_in?

    now = DateTime.now

    if now < $voting_opens_at
      raise ActiveRecord::RecordNotFound
    end

    if $hugo_closed_at < now
      raise ActiveRecord::RecordNotFound
    end

    if !@reservation.can_vote?
      raise ActiveRecord::RecordNotFound
    end

    if support_signed_in?
      flash[:notice] = "Can't vote when signed in as support"
      redirect_to @reservation
    end
  end
end
