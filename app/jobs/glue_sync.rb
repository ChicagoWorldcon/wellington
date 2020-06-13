# Copyright 2020 Matthew B. Gray
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

require "net/http"

# GlueSync sends users to Gloo
class GlueSync
  include Sidekiq::Worker

  def perform(email)
    user = User.find_by!(email: email)
    remote_user = get_remote_user(email)
    updated_remote_user = GlueContact.new(user, remote_user: remote_user).call
    post(users_url, updated_remote_user.to_json)
  end

  private

  def get_remote_user(email)
    user = get(users_url(email))
    return {} if user.code != 200

    # Because roles are not attached to users in the current API
    # This may change, and if it does we can simplify this
    roles = get(users_url(email, "roles"))
    user_data = JSON.parse(user.body, symbolize_names: true)
    role_data = JSON.parse(roles.body, symbolize_names: true)
    user_data.merge(role_data)
  end

  private

  def post(url, body)
    HTTParty.post(url, headers: standard_headers, body: body).tap do |resp|
      raise "service down" if resp.code.in?(500..599)
    end
  end

  def get(url)
    HTTParty.get(url, headers: standard_headers).tap do |resp|
      raise "service down" if resp.code.in?(500..599)
    end
  end

  def users_url(*resources)
    # e.g. "https://api.thefantasy.network/v1/users"
    # e.g. "https://api.thefantasy.network/v1/users/super@man.net"
    # e.g. "https://api.thefantasy.network/v1/users/super@man.net/roles"
    url_parts = [ENV.fetch("GLUE_BASE_URL"), "users"] + resources
    url_parts.join("/")
  end

  def standard_headers
    {
      "Content-Type" => "application/json",
      "Authorization" => ENV.fetch("GLUE_AUTHORIZATION_HEADER"),
    }
  end
end
