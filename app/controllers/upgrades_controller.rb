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

class UpgradesController < ApplicationController
  before_action :lookup_reservation
  before_action :lookup_offer, except: :index

  def index
    @offers = UpgradeOffer.from(@reservation.membership)
  end

  def new
  end

  def create
    upgrader = UpgradeMembership.new(@reservation, to: @my_offer.to_membership)
    if !upgrader.call
      Rails.logger.error("Failed to upgrade #{current_user.id} to #{@reservation.membership.name}")
      flash[:error] = %{
        Sorry. #{params[:offer]}
        from #{@reservation.membership}
        could not be upgraded at this time
      }
      return
    end

    flash[:notice] = %{
      You've just upgraded #{@my_offer.from_membership}
      to #{@my_offer.to_membership}
    }
    redirect_to new_charge_path(reservation: @reservation)
  end

  private

  def lookup_offer
    @my_offer = UpgradeOffer.from(@reservation.membership).find do |offer|
      offer.hash == params[:offer]
    end

    if !@my_offer.present?
      redirect_to reservations_path
      flash[:error] = %{
        Sorry. #{params[:offer]}
        from #{@reservation.membership}
        is no longer available
      }
    end
  end
end
