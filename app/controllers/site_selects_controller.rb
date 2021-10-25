# frozen_string_literal: true

# COpyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# 1-Oct-21 FNB adapted for site selection token and payment

class SiteSelectsController < ApplicationController
 
  #before_action :check_access!
  before_action :lookup_reservation!
  def show
    # current_user.update!(hugo_download_counter: current_user.hugo_download_counter + 1)

    # #hugo_packet_path = [ENV["HUGO_PACKET_PREFIX"], params[:id]].join("/") #S3 version
    # hugo_packet_path = params[:id] #Spaces version
    # s3_object = Aws::S3::Object.new(
    #   key: hugo_packet_path,
    #   bucket_name: ENV['HUGO_PACKET_BUCKET'],
    #   client: s3_client,
    # )
    hotel_path = params[:id]
    redirect_to ENV['HOTEL_LINK']
  end

  private

  def check_access!
    if !user_signed_in?
      flash["notice"] = "Please log in to access hotel reservation information"
      redirect_to root_path
      return
    end

    if current_user.reservations.none?
      flash["notice"] = "To access hotel reservation information, please purchase an attending membership."
      redirect_to memberships_path
      return
    end

    # Just need minimum instalment to count
    paid_reservations = current_user.reservations.distinct.joins(:charges).merge(Charge.successful)
    if paid_reservations.none?(&:can_attend?)
      flash["notice"] = "To access hotel reservation information, please ensure one of your memberships is an attending membership."
      redirect_to reservations_path
      return
    end
  end

  def trigger_site_mailer(charge, outstanding_before_charge, charge_amount)
      SiteMailer.paid(
        user: current_user,
        charge: charge,
      ).deliver_later
  end



end


#from charges

# Test cards are here: https://stripe.com/docs/testing
#class ChargesController < ApplicationController

#   before_action :lookup_reservation!

#   def new
#     if @reservation.paid?
#       redirect_to reservations_path, notice: "You've paid for this #{@reservation.membership} membership"
#       return
#     end

#     @membership = @reservation.membership
#     @outstanding_amount = AmountOwedForReservation.new(@reservation).amount_owed

#     price_steps = PaymentAmountOptions.new(@outstanding_amount).amounts

#     @price_options = price_steps.reverse.map do |price|
#       [price.format, price.cents]
#     end
#   end

#   def create
#     charge_amount = Money.new(params[:amount].to_i)

#     outstanding_before_charge = AmountOwedForReservation.new(@reservation).amount_owed

#     allowed_charge_amounts = PaymentAmountOptions.new(outstanding_before_charge).amounts
#     if !charge_amount.in?(allowed_charge_amounts)
#       flash[:error] = "Amount must be one of the provided payment amounts"
#       redirect_to new_reservation_charge_path
#       return
#     end

#     service = Money::ChargeCustomer.new(
#       @reservation,
#       current_user,
#       params[:stripeToken],
#       outstanding_before_charge,
#       charge_amount: charge_amount,
#     )

#     charge_successful = service.call
#     if !charge_successful
#       flash[:error] = service.error_message
#       redirect_to new_reservation_charge_path
#       return
#     end

#     trigger_payment_mailer(service.charge, outstanding_before_charge, charge_amount)

#     message = "Thank you for your #{charge_amount.format} payment"
#     (message += ". Your #{@reservation.membership} membership has been paid for.") if @reservation.paid?

#     redirect_to reservations_path, notice: message
#   end

#   private


# end
