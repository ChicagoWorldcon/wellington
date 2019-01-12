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
    redirect_to root_path if signed_in?
    @token = LoginToken.new
  end

  def show
    lookup_user_query = Token::LookupOrCreateUser.new(token: params[:id], secret: secret)
    user = lookup_user_query.call
    if user.present?
      sign_in user
      flash[:notice] = "Logged in as #{user.email}"
      redirect_to root_path
    else
      error_message = lookup_user_query.errors.to_sentence.humanize
      flash[:notice] = "#{error_message}. Please send another link, or email us at registrations@conzealand.nz"
      redirect_to new_login_token_path
    end
  end

  def create
    send_link_command = Token::SendLink.new(email: params[:email], secret: secret)
    if send_link_command.call
      flash[:notice] = "Email sent, please check #{params[:email]} for your login link"
      redirect_to root_path
    else
      flash[:notice] = send_link_command.errors.to_sentence
      redirect_to new_login_token_path
    end
  end

  def kansa_login_link
    sign_out current_user if signed_in?
    flash[:notice] = "That login link has expired. Please send another link, or email us at registrations@conzealand.nz"
    redirect_to new_login_token_path
  end

  private

  # Check README.md if this fails for you
  def secret
    ENV["JWT_SECRET"]
  end
end
