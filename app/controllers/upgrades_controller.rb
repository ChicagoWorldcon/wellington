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
  before_action :lookup_purchase

  def edit
    if !params[:offer].present?
      redirect_to purchases_path
      return flash[:notice] = "Sorry, something went wrong with your upgrade. Please try again."
    end

    # Find the offer that matches the our user clicked on
    offer = UpgradeOffer.from(@purchase.membership).find do |offer|
      offer.to_s == params[:offer]
    end

    if !offer.present?
      redirect_to purchases_path
      return flash[:notice] = "Sorry. #{params[:offer]} from #{@purchase.membership} is no longer available"
    end

    upgrader = UpgradeMembership.new(@purchase, to: offer.to_membership)
    if !upgrader.call
      Rails.logger.error("Failed to upgrade #{current_user.id} to #{@purchase.membership.name}")
      return flash[:notice] = "Sorry. #{params[:offer]} from #{@purchase.membership} could not be upgraded at this time"
    end

    redirect_to new_charge_path(purchaseId: @purchase.id)
    flash[:notice] = "Congratulations! You now hold a #{offer.to_membership}"
  end
end
