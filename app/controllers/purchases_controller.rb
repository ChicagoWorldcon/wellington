# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 AJ Esler
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

class PurchasesController < ApplicationController
  before_action :lookup_purchase, only: [:show, :update]

  # TODO(issue #24) list all members for people not logged in
  def index
    if user_signed_in?
      @my_purcahses = Purchase.joins(:user).where(users: {id: current_user})
      @my_purcahses = @my_purcahses.joins(:membership)
      @my_purcahses = @my_purcahses.includes(:charges).includes(active_claim: :detail)
    end
  end

  def new
    @purchase = Purchase.new
    @detail = Detail.new
    @offers = MembershipOffer.options
    @paperpubs = Detail::PAPERPUBS_OPTIONS.map { |o| [o.humanize, o] }
  end

  def show
    @detail = @purchase.active_claim.detail || Detail.new
    @my_offer = MembershipOffer.new(@purchase.membership)
    @outstanding_amount = AmountOwedForPurchase.new(@purchase).amount_owed
    @paperpubs = Detail::PAPERPUBS_OPTIONS.map { |o| [o.humanize, o] }
  end

  def create
    current_user.transaction do
      matching_offer = MembershipOffer.options.find do |offer|
        offer.to_s == params[:offer]
      end

      # TODO nicer errors
      raise "Offer not available to user" if !matching_offer.present?

      purchase_service = PurchaseMembership.new(matching_offer.membership, customer: current_user)
      new_purchase = purchase_service.call

      # TODO nicer errors
      raise "Failed to purchase membership" if !new_purchase.present?

      detail = Detail.new(params.require(:detail).permit(Detail::PERMITTED_PARAMS))
      detail.claim = new_purchase.active_claim

      # TODO nicer errors
      detail.save!

      flash[:notice] = "Congratulations member ##{new_purchase.membership_number}! You've just reserved a #{matching_offer.membership} membership"
      if new_purchase.membership.price.zero?
        redirect_to purchases_path
      else
        redirect_to new_charge_path(purchaseId: new_purchase.id)
      end
    end
  end

  def update
    current_user.transaction do
      current_details = @purchase.active_claim.detail
      submitted_values = params.require(:detail).permit(Detail::PERMITTED_PARAMS)
      if current_details.update(submitted_values)
        flash[:notice] = "Your details have been saved against Member ##{@purchase.membership_number}"
        redirect_to purchases_path
      else
        flash[:error] = current_details.errors.full_messages.to_sentence
        redirect_to purchase_path(@purchase)
      end
    end
  end
end
