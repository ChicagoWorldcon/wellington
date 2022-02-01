# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 Steven C Hartley
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

class UserTokensController < ApplicationController
  def new
    redirect_to root_path if signed_in?
    @token = UserToken.new
  end

  def show
    lookup_user_query = Token::LookupOrCreateUser.new(token: params[:id], secret: secret)
    redirect_to login_user_with(lookup_user_query)
  end

  def create
    target_email = params[:email]&.strip
    new_user = User.find_or_initialize_by_canonical_email(EmailAddress.canonical(target_email))

    if !new_user.valid? # ...invalid user
      flash[:error] = new_user.errors.full_messages.to_sentence
      redirect_to referrer_path
      return
    elsif !new_user.persisted? # ...valid and never been seen before
      new_user.user_provided_email = target_email
      new_user.save!
      sign_in(new_user)
      flash[:notice] = %(
        Welcome #{target_email}!
        Because this is the first time we've seen you, you're automatically signed in.
        In the future, you'll have to check your email.
      )
      redirect_to referrer_path
      return
    end

    # From here we're in the login flow for an existing user. We are going to send them a token link AND a code for the
    # secret, and then redirect to a form where they can enter the shortcode.
    canonical_email = EmailAddress.canonical(target_email)
    send_link_command = Token::SendLink.new(email: canonical_email, secret: secret, path: reservations_path)
    if send_link_command.call
      flash[:notice] = "Email sent, please check #{target_email} for your login link"
      flash[:notice] += " (http://localhost:1080)" if Rails.env.development?

      redirect_to enter_user_tokens_path
    else
      flash[:error] = send_link_command.errors.to_sentence
      redirect_to referrer_path
    end
  end

  def kansa_login_link
    sign_out(current_user) if signed_in?
    flash[:error] = "That login link has expired. Please send another link, or email us at #{$member_services_email}"
    redirect_to root_path
  end

  def logout
    if signed_in?
      flash[:notice] = "Signed out #{current_user.email}"
      sign_out(current_user)
    end
    redirect_to root_path
  end

  def enter
    if signed_in?
      redirect_to reservations_path
      return
    end

    if params[:shortcode].present?
      lookup_query = Token::LookupUserByShortcode.new(shortcode: params[:shortcode], secret: secret)
      destination = login_user_with(lookup_query)
      redirect_to destination
      lookup_query.cleanup!
    else
      flash[:info] = "Log in with your emailed shortcode"
    end
  end

  private

  def login_user_with(query)
    user = query.call
    redirect_path = nil
    if user.present?
      sign_in user
      flash[:notice] = "Logged in as #{user.email}"
      redirect_path = query.path
    else
      error_message = query.errors.to_sentence.humanize
      flash[:error] = "#{error_message}. Please send another link, or email us at #{$member_services_email}"
    end
    redirect_path || root_path
  end

  # Check README.md if this fails for you
  def secret
    ENV["JWT_SECRET"]
  end

  def referrer_path
    return session[:return_path] if session[:return_path].present?

    return "/" unless request.referrer.present?

    uri = URI(request.referrer)
    "#{uri.path}?#{uri.query}" if uri.query.present?

    uri.path
  end
end
