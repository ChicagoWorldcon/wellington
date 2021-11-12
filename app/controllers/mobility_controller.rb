# frozen_string_literal: true

# COpyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# 13-Jun-21 FNB adapted for Hugo packet to only show hotel info to attending members.
# 11-Nov-21 FNB adapted for Mobility device rentals

class MobilityController < ApplicationController
  # Packet = Struct.new(:prefix, :blob) do
  #   include ActionView::Helpers::NumberHelper

  #   delegate :size, :key, to: :blob

  #   def downloadable?
  #     size > 0
  #   end

  #   def file_name
  #     key.sub(prefix + '/', '')
  #   end

  #   def download_size
  #     number_to_human_size(size)
  #   end
  # end

  before_action :check_access!

  # def index
  #   list_objects = s3_client.list_objects(
  #     bucket: ENV["HUGO_PACKET_BUCKET"],
  #     prefix: ENV["HUGO_PACKET_PREFIX"],
  #   )

  #   @packets = list_objects.contents.map do |blob|
  #     Packet.new(list_objects.prefix, blob)
  #   end

  #   @blobs = list_objects
  # end

  def show
    # current_user.update!(hugo_download_counter: current_user.hugo_download_counter + 1)

    # #hugo_packet_path = [ENV["HUGO_PACKET_PREFIX"], params[:id]].join("/") #S3 version
    # hugo_packet_path = params[:id] #Spaces version
    # s3_object = Aws::S3::Object.new(
    #   key: hugo_packet_path,
    #   bucket_name: ENV['HUGO_PACKET_BUCKET'],
    #   client: s3_client,
    # )
    mobility_path = params[:id]
    redirect_to ENV['MOBILITY_LINK']
  end

  private

  def check_access!
    if !user_signed_in?
      flash["notice"] = "Please log in to access mobility devide reservation information"
      redirect_to root_path
      return
    end

    if current_user.reservations.none?
      flash["notice"] = "To access mobility device reservation information, please purchase an attending membership."
      redirect_to memberships_path
      return
    end

    # Just need minimum instalment to count
    paid_reservations = current_user.reservations.distinct.joins(:charges).merge(Charge.successful)
    if paid_reservations.none?(&:can_attend?)
      flash["notice"] = "To access mobility device reservation information, please ensure one of your memberships is an attending membership."
      redirect_to reservations_path
      return
    end
  end


  # def s3_client
  #   @s3_client ||= Aws::S3::Client.new(
  #     access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  #     secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  #     endpoint: ENV['AWS_ENDPOINT'],
  #     region: ENV['AWS_REGION']
  #   )
  # end
end
