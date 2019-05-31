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

#
class TransfersController < ApplicationController
  helper PurchasesHelper

  before_action :assert_support!
  before_action :setup_transfer, only: [:show, :update]

  def new
    @purchase = Purchase.find(params[:purchase_id])
    @detail = @purchase.active_claim.detail
  end

  def show
  end

  def update
    current_support.transaction do
      owner_detail = @transfer.detail

      service = Purchase::ApplyTransfer.new(@transfer.purchase, from: @transfer.from_user, to: @transfer.to_user)
      new_claim = service.call

      if !new_claim
        flash[:error] = service.error_message
        redirect_to purchases_path
        return
      end

      if @transfer.copy_details?
        new_claim.update!(detail: owner_detail.dup)
      end

      flash[:notice] = %{
        Transferred membership ##{@transfer.purchase.membership_number}
        to #{@transfer.to_user.email}
      }

      MembershipMailer.transfer(
        from: @transfer.from_user.email,
        to: @transfer.to_user.email,
        owner_name: owner_detail&.to_s,
        membership_number: @transfer.purchase.membership_number,
      ).deliver_later

      redirect_to purchases_path
    end
  end

  private

  def setup_transfer
    @transfer = Purchase::PlanTransfer.new(
      new_owner: params[:id],
      purchase_id: params[:purchase_id],
      copy_details: params.dig(:purchase_plan_transfer, :copy_details),
    )

    if !@transfer.valid?
      flash[:error] = @transfer.errors.full_messages.to_sentences
      redirect_to purchases_path
    end
  end
end
