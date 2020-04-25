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
  helper ReservationsHelper

  before_action :authenticate_support!
  before_action :setup_transfer, only: [:show, :update]

  def new
    @reservation = Reservation.find(params[:reservation_id])
    @contact = @reservation.active_claim.conzealand_contact
  end

  def show
  end

  def update
    current_support.transaction do
      owner_contact = @transfer.copy_contact

      service = ApplyTransfer.new(
        @transfer.reservation,
        from: @transfer.from_user,
        to: @transfer.to_user,
        audit_by: current_support.email,
        copy_contact: @transfer.copy_contact?,
      )
      new_claim = service.call
      if !new_claim
        flash[:error] = service.error_message
        redirect_to reservations_path
        return
      end

      MembershipMailer.transfer(
        from: @transfer.from_user.email,
        to: @transfer.to_user.email,
        owner_name: owner_contact&.to_s,
        membership_number: @transfer.reservation.membership_number,
      ).deliver_later

      flash[:notice] = %{
        Transferred membership ##{@transfer.reservation.membership_number}
        to #{@transfer.to_user.email}
      }

      redirect_to reservations_path
    end
  end

  private

  def setup_transfer
    @transfer = PlanTransfer.new(
      new_owner: params[:id],
      reservation_id: params[:reservation_id],
      copy_contact: params.dig("plan_transfer", "copy_contact"),
    )

    if !@transfer.valid?
      flash[:error] = @transfer.errors.full_messages.to_sentence
      redirect_to reservations_path
    end
  end
end
