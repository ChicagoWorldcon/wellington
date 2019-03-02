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
  before_action :lookup_purchase, only: [:show, :edit]

  # TODO(issue #24) list all members for people not logged in
  def index
    if current_user.present?
      @my_purcahses = Purchase.joins(:user).where(users: {id: current_user})
      @my_purcahses = @my_purcahses.joins(:membership)
      @my_purcahses = @my_purcahses.includes(:charges).includes(active_claim: :detail)
    end

    if current_support.present?
      @everyones_purchases = Purchase.includes(:user).joins(:membership)
    end
  end

  def new
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

      flash[:notice] = "Congratulations member #{new_purchase.membership_number}! You just reserved a #{matching_offer.membership} membership <3"
      redirect_to new_charge_path(purchaseId: new_purchase.id)
    end
  end

  private

  def lookup_purchase
    visible_purchases = Purchase.joins(:user)
    if !support_signed_in?
      visible_purchases = visible_purchases.where(users: { id: current_user })
    end
    @purchase = visible_purchases.find_by!(membership_number: params[:id])
  end
end
