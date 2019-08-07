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
  layout "conzealand"

  def member_services_user
    @member_services_user ||= User.find_or_create_by(email: $member_services_email)
  end

  protected

  def lookup_reservation!
    visible_reservations = Reservation.joins(:user)
    if !support_signed_in?
      visible_reservations = visible_reservations.where(users: { id: current_user })
    end
    @reservation = visible_reservations.find(params[:reservation_id] || params[:id])
  end

  def set_kiosk!
    # If there's an expired kiosk session, reset it
    if session[:kiosk].present? && session[:kiosk] < Time.now
      session.delete(:kiosk)
    end

    # If there's no kiosk session, force support sign in
    if session[:kiosk].nil?
      authenticate_support!
    end

    # If support signed in, sign out and set kiosk expiry
    if support_signed_in?
      sign_out
      session[:kiosk] = 2.weeks.from_now
    end

    # Set kiosk mode, used for views and view actions
    @kiosk = true
  end

  def kiosk?
    @kiosk.present?
  end
end
