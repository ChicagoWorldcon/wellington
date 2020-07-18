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

class NominationsController < ApplicationController
  before_action :lookup_reservation!
  before_action :check_access!
  before_action :lookup_election!
  before_action :lookup_legal_name_or_redirect

  def show
    builder = MemberNominationsByCategory.new(categories: ordered_categories_for_election, reservation: @reservation)
    builder.from_reservation
    @nominations_by_category = builder.nominations_by_category
    if !@nominations_by_category.present?
      flash[:error] = builder.error_message
      redirect_to reservations_path
      return
    end

    @privacy_warning = !hugo_admin_signed_in? && current_user.reservations.count > 1
  end

  def update
    builder = MemberNominationsByCategory.new(categories: ordered_categories_for_election, reservation: @reservation)
    builder.from_params(params)
    builder.save

    if hugo_admin_signed_in?
      @reservation.user.notes.create!(
        content: %{
          Nomination form updated by hugo admin #{current_operator.email}
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

  def check_access!
    # You have unrestricted access if you're a hugo admin
    return true if hugo_admin_signed_in?

    errors = []
    errors << "nominations are closed" if !HugoState.new.has_nominations_opened?
    errors << "this membership doesn't have nomination rights" if !@reservation.can_nominate?
    errors << "unavailable when signed in as operator" if operator_signed_in?

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

  def nomination_params
    params.require(:category).require(:nomination)
  end

  def ordered_categories_for_election
    @election.categories.order(:order, :id)
  end
end
