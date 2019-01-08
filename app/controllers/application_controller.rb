# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
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

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user_from_token!

  private

  def authenticate_user_from_token!
    if params[:token].present?
      raise "Missing JWT_SECRET" unless ENV["JWT_SECRET"].present?
      user = LoginToken.decode_and_lookup!(ENV["JWT_SECRET"], jwt_token: params[:token])
      sign_in user, store: false
    end
  end
end
