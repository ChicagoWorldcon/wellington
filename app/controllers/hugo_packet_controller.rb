# frozen_string_literal: true

# Copyright 2020 Steven Ensslen
# Copyright 2020 Matthew B. Gray
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

require "aws-sdk-s3"

class HugoPacketController < ApplicationController
  Packet = Struct.new(:prefix, :blob) do
    include ActionView::Helpers::NumberHelper

    delegate :size, :key, to: :blob

    def downloadable?
      size > 0
    end

    def file_name
      key.sub(prefix + "/", "")
    end

    def download_size
      number_to_human_size(size)
    end
  end

  before_action :check_access!

  def index
    list_objects = s3_client.list_objects(
      bucket: ENV["HUGO_PACKET_BUCKET"],
      prefix: ENV["HUGO_PACKET_PREFIX"]
    )

    @packets = list_objects.contents.map do |blob|
      Packet.new(list_objects.prefix, blob)
    end

    @blobs = list_objects
  end

  def show
    current_user.update!(hugo_download_counter: current_user.hugo_download_counter + 1)

    hugo_packet_path = [ENV["HUGO_PACKET_PREFIX"], params[:id]].join("/")
    s3_object = Aws::S3::Object.new(
      key: hugo_packet_path,
      bucket_name: ENV["HUGO_PACKET_BUCKET"],
      client: s3_client
    )

    redirect_to s3_object.presigned_url(:get, expires_in: 1.hour.to_i)
  end

  private

  def check_access!
    unless user_signed_in?
      flash["notice"] = "Please log in to download the Hugo Packet"
      redirect_to root_path
      return
    end

    if current_user.reservations.none?
      flash["notice"] = "To download the Hugo Packet, please purchase a membership with voting rights"
      redirect_to memberships_path
      return
    end

    # Just need minimum instalment to count
    paid_reservations = current_user.reservations.distinct.joins(:charges).merge(Charge.successful)
    if paid_reservations.none?(&:can_vote?)
      flash["notice"] =
        "To download the Hugo Packet, please ensure one of your memberships has at least the minimum instalment and voting rights"
      redirect_to reservations_path
      nil
    end
  end

  def s3_client
    # if we are setting the endpoint, we use a custom S3 client setup
    @s3_client ||= if ENV["AWS_ENDPOINT"]
                     Aws::S3::Client.new(
                       access_key_id: ENV["AWS_ACCESS_KEY_ID"],
                       secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
                       endpoint: ENV["AWS_ENDPOINT"],
                       region: ENV["AWS_REGION"]
                     )
                   else
                     Aws::S3::Client.new
                   end
  end
end
