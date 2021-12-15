# frozen_string_literal: true

# COpyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# 1-Oct-21 FNB adapted for discord token generation

class DiscordController < ApplicationController
 
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
    #hotel_path = params[:id]        #this should likely be removed TODO
    #redirect_to ENV['HOTEL_LINK']
  end

  private

  def check_access!
    if !user_signed_in?
      flash["notice"] = "Please log in to access Discord information"
      redirect_to root_path
      return
    end

    if current_user.reservations.none?
      flash["notice"] = "To access Discord information, please purchase a membership."
      redirect_to memberships_path
      return
    end

    # Just need minimum instalment to count
    paid_reservations = current_user.reservations.distinct.joins(:charges).merge(Charge.successful)
    if paid_reservations.none?(&:can_attend?)
      flash["notice"] = "To access discord information, please ensure one of your memberships is an attending membership."
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

