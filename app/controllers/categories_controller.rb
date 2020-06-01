
# Copyright 2020 Steven Ensslen
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

class CategoriesController < ApplicationController
    # controller only accessed by XHR, see https://stackoverflow.com/a/43122403/7359502
    skip_before_action :verify_authenticity_token

    before_action :lookup_reservation!
    before_action :check_access!
    before_action do
        lookup_election!(election: params[:finalist_id])
    end
    #before_action :lookup_legal_name_or_redirect

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
      @votes_by_category = builder.votes_by_category
  
      if request.xhr?
        category_decorator = CategoryFormDecorator.new(@category, @votes_by_category[@category])
        render json: {
          updated_heading: category_decorator.heading,
          updated_classes: category_decorator.accordion_classes,
        }
        return
      end
  
    end
  
    private
  
    def check_access!
      # You have unrestricted access if you're a hugo admin
      return true if hugo_admin_signed_in?
  
      errors = []
      errors << "votes are closed" if !HugoState.new.has_voting_opened?
      errors << "this membership doesn't have voting rights" if !@reservation.can_vote?
      errors << "unavailable when signed in as support" if support_signed_in?
  
      if errors.any?
        flash[:notice] = errors.to_sentence
        redirect_to @reservation
      end
    end
  
    def lookup_legal_name_or_redirect
      detail = @reservation.active_claim.contact
      if detail.present?
        @legal_name = detail.hugo_name
        return
      end
  
      if @reservation.membership.name == "dublin_2019"
        @legal_name = "Dublin Friend"
        return
      end
  
      flash[:notice] = "Please enter your details to nominate for hugo"
      redirect_to @reservation
    end

    def ordered_categories_for_election
      @election.categories.order(:order, :id)
    end
  end
  
