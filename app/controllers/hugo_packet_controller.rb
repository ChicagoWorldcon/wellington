# Copyright 2020 Steven Ensslen
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

class HugoPacketController < ApplicationController
  def index
    require 'aws-sdk'
    @s3_client = Aws::S3::Client.new
    @blobs = @s3_client.list_objects_v2({bucket: ENV['HUGO_PACKET_BUCKET'], prefix: ENV['HUGO_PACKET_PREFIX']})
  end
end
