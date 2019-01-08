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

class LoginTokensController < ApplicationController
  def new
    @token = LoginToken.new
  end

  def show
    @token = LoginToken.decode(token: params[:id], secret: secret)
    if !@token.valid?
      flash[:notice] = @token.errors.full_messages.to_sentence
      redirect_to new_login_token_path
    else
      user = @token.find_user
      sign_in user
      flash[:notice] = "Logged in as #{user.email}"
      redirect_to "/"
    end
  end

  def create
    @token = LoginToken.new(email: params[:email], secret: secret)
    if !@token.valid?
      flash[:notice] = @token.errors.full_messages.to_sentence
      redirect_to new_login_token_path
    else
      flash[:notice] = "Emailed #{@token.email} with https://localhost:3000/login_tokens/#{@token.encode}"
      redirect_to root_path
    end
  end

  private

  # Check README.md if this fails for you
  def secret
    ENV["JWT_SECRET"] or raise "Cannot find JWT_SECRET in Environment"
  end
end
