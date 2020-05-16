class HugoPacketController < ApplicationController
    def index
        require 'aws-sdk'
        @s3_client = Aws::S3::Client.new
        @blobs = @s3_client.list_objects_v2({bucket: ENV['HUGO_PACKET_BUCKET'], prefix: ENV['HUGO_PACKET_PREFIX']})
    end
end
