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

class Operator::RightsController < ApplicationController
  before_action :authenticate_operator!
  before_action :lookup_reservation!

  # create modifies the rights on the underlying reservation rather than creating a new one. This bends convention
  # slightly because separating setting of rights from other user actions on reservation makes it easier to make sure
  # it's not part of the user flows. If you want to inline this, maybe consider detection of user intent through various
  # strong param lookups
  def create
    if !@reservation.disabled?
      @reservation.update!(state: Reservation::DISABLED)
    elsif instalment?
      @reservation.update!(state: Reservation::INSTALMENT)
    else
      @reservation.update!(state: Reservation::PAID)
    end

    if @reservation.disabled?
      flash[:notice] = "Disabled membership rights for member ##{@reservation.membership_number}"
    else
      flash[:notice] = "Enabled membership rights for member ##{@reservation.membership_number}"
    end

    redirect_to reservation_path(@reservation)
  end

  private

  def instalment?
    shortfall > 0
  end

  def shortfall
    AmountOwedForReservation.new(@reservation).amount_owed
  end
end
