class HugoPacketController < ApplicationController
    def index
        doc_download
      end
    
      def doc_download
    
        require 'aws-sdk'
    
        Aws.config.update(
            region: 'ap-southeast-2',
            endpoint: 'https://s3.ap-southeast-2.amazonaws.com',
        )
    
        @s3_client = Aws::S3::Client.new
    
        @blobs = @s3_client.list_objects_v2({bucket: 'django-spending', prefix:'admin/css'})
    end
end
