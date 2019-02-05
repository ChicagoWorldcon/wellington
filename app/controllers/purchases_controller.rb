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

class PurchasesController < ApplicationController
  before_action :lookup_purchase, only: :show

  # TODO(issue #24) list all members for people not logged in
  # TODO(issue #23) list all members and details for support
  def index
    if current_user.present?
      @my_purcahses = Purchase.joins(:user).where(users: {id: current_user})
      @my_purcahses = @my_purcahses.joins(:membership)
      @my_purcahses = @my_purcahses.includes(:charges).includes(active_claim: :detail)
    end

    if Rails.env.development?
      @everyones_purchases = Purchase.includes(:user).joins(:membership)
    end
  end

  def new
    @detail = Detail.new
    @offers = MembershipOffer.options
    @paperpubs = Detail::PAPERPUBS_OPTIONS.map { |o| [o.humanize, o] }
  end

  def show
    @detail = @purchase.active_claim.detail
    @my_offer = MembershipOffer.new(@purchase.membership)
    @offers = MembershipOffer.options
    @paperpubs = Detail::PAPERPUBS_OPTIONS.map { |o| [o.humanize, o] }
  end

  private

  def lookup_purchase
    @purchase = Purchase.find_by!(membership_number: params[:id])
  end
end
