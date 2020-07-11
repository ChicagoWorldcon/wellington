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

class Operator::TheFantasyNetworkRolesController < ApplicationController
  before_action :authenticate_operator!
  before_action :lookup_user!
  before_action :lookup_gloo_contact!

  def index
    all_roles = as_hash(GlooContact::DISCORD_ROLES, value: false)
    remote_roles = as_hash(@gloo_contact.discord_roles, value: true)
    @current_roles = all_roles.merge(remote_roles)
  end

  def create
    @gloo_contact.discord_roles = posted_discord_roles
    @gloo_contact.save!
  end

  private

  def posted_discord_roles
    GlooContact::DISCORD_ROLES.select { |role| params[role] == "1" }
  end

  def as_hash(list, value:)
    list.zip([value]*list.length).to_h
  end
end
