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
  layout ENV.fetch("WORLDCON_THEME", "conzealand")

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
end
