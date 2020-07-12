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


# FinalistsController collects Hugo votes and shows the Hugo votes by a user
class FinalistsController < ApplicationController
  # controller also accessed by XHR, see https://stackoverflow.com/a/43122403/7359502
  skip_before_action :verify_authenticity_token

  before_action :lookup_reservation!
  before_action :check_access!
  before_action :lookup_election!
  before_action :lookup_legal_name_or_redirect

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

    if ! params[:category].respond_to? :each then
      categories = params[:category]
    else
      categories = [ params[:category] ]
    end

    votes = []
    categories.each do |cat|
      votes += cat[:finalists]
    end

    vote_finalists = []
    votes.each do |vote|
      vote_finalists << vote[:id]
    end

    @reservation.transaction do
      existing_votes = @reservation.ranks.where(finalist: vote_finalists)
      existing_votes.destroy_all

      votes.each do |vote|
        @reservation.ranks << Rank.new(
          position: vote[:rank],
          reservation_id: @reservation[:id],
          finalist_id: vote[:id]
        )
      end

      if hugo_admin_signed_in?
        @reservation.user.notes.create!(
          content: %{
            Voting form updated by hugo admin #{current_operator.email}
            on behalf of member ##{@reservation.membership_number}
          }.strip_heredoc
        )
      end
    end
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

    errors = []
    errors << "voting is not open" if !HugoState.new.has_voting_opened?
    errors << "signed in as operator" if operator_signed_in?
    errors << "this membership doesn't have voting rights" if !@reservation.can_vote?

    if errors.any?
      flash[:notice] = errors.to_sentence
      redirect_to @reservation
    end
  end

  def ordered_categories_for_election
    @election.categories.order(:order, :id)
  end

  def lookup_legal_name_or_redirect
    detail = @reservation.active_claim.contact
    if detail.present?
      @legal_name = detail.hugo_name
      return
    end

    flash[:notice] = "Please enter your details to nominate for hugo"
    redirect_to @reservation
  end
end
