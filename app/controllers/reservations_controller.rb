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

class ReservationsController < ApplicationController
  before_action :lookup_reservation!, only: [:show, :update]
  before_action :lookup_offer, only: [:new, :create]
  before_action :setup_paperpubs, except: :index

  # TODO(issue #24) list all members for people not logged in
  def index
    if user_signed_in?
      @my_purcahses = Reservation.joins(:user).where(users: {id: current_user})
      @my_purcahses = @my_purcahses.joins(:membership)
      @my_purcahses = @my_purcahses.includes(:charges).includes(active_claim: :conzealand_contact)
    end
  end

  def new
    @reservation = Reservation.new
    @contact = ConzealandContact.new
    @offers = MembershipOffer.options
    if user_signed_in?
      @current_memberships = MembershipsHeldSummary.new(current_user).to_s
    else
      session[:return_path] = request.fullpath
    end
  end

  def show
    @contact = @reservation.active_claim.conzealand_contact || ConzealandContact.new
    @my_offer = MembershipOffer.new(@reservation.membership)
    @outstanding_amount = AmountOwedForReservation.new(@reservation).amount_owed
    @notes = Note.joins(user: :claims).where(claims: {reservation_id: @reservation})
  end

  def create
    current_user.transaction do
      @contact = ConzealandContact.new(params.require(:conzealand_contact).permit(ConzealandContact::PERMITTED_PARAMS))
      if !@contact.valid?
        @reservation = Reservation.new
        flash[:error] = @contact.errors.full_messages.to_sentence
        render "/reservations/new"
        return
      end

      service = ClaimMembership.new(@my_offer.membership, customer: current_user)
      new_reservation = service.call
      @contact.claim = new_reservation.active_claim
      @contact.save!

      flash[:notice] = %{
        Congratulations member ##{new_reservation.membership_number}!
        You've just reserved a #{@my_offer.membership} membership
      }

      if new_reservation.membership.price.zero?
        redirect_to reservations_path
      else
        redirect_to new_reservation_charge_path(new_reservation)
      end
    end
  end

  def update
    @reservation.transaction do
      current_contact = @reservation.active_claim.conzealand_contact
      current_contact ||= ConzealandContact.new(claim: @reservation.active_claim)
      submitted_values = params.require(:conzealand_contact).permit(ConzealandContact::PERMITTED_PARAMS)
      if current_contact.update(submitted_values)
        flash[:notice] = "Details for #{current_contact} member ##{@reservation.membership_number} have been updated"
        redirect_to reservations_path
      else
        @contact = @reservation.active_claim.conzealand_contact || ConzealandContact.new
        @my_offer = MembershipOffer.new(@reservation.membership)
        @outstanding_amount = AmountOwedForReservation.new(@reservation).amount_owed
        flash[:error] = current_contact.errors.full_messages.to_sentence
        render "reservations/show"
      end
    end
  end

  private

  def lookup_offer
    @my_offer = MembershipOffer.options.find do |offer|
      offer.hash == params[:offer]
    end

    if !@my_offer.present?
      flash[:error] = t("errors.offer_unavailable", offer: params[:offer])
      redirect_to memberships_path
    end
  end

  def setup_paperpubs
    @paperpubs = ConzealandContact::PAPERPUBS_OPTIONS.map { |o| [o.humanize, o] }
  end
end
