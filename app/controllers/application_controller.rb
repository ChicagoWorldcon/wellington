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

class ApplicationController < ActionController::Base
  include ThemeConcern
  layout theme_layout

  def member_services_user
    @member_services_user ||= User.find_or_create_by(email: $member_services_email)
  end

  protected

  def lookup_reservation!
    visible_reservations = Reservation.joins(:user)

    if !operator_signed_in?
      visible_reservations = visible_reservations.where(users: { id: current_user })
    end

    @reservation = visible_reservations.find_by(id: params[:reservation_id] || params[:id])

    if @reservation.nil?
      head :forbidden
    end
  end

  # Assumes i18n_key as id
  def lookup_election!
    @election = Election.find_by!(i18n_key: params[:finalist_id] || params[:id])
  end

  def lookup_legal_name_or_redirect
    detail = @reservation.active_claim.detail
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

  def hugo_admin_signed_in?
    operator_signed_in? && current_operator.hugo_admin.present?
  end
end
