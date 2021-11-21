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

# Token::SendLink creates and mails out a JWT token embedded in a URL
# This presents the 'Login Link' logic that is the backbone of how a user authetnicates with the members area
class Token::SendLink
  TOKEN_DURATION = 30.minutes

  attr_reader :email, :secret, :path, :shortcode

  def initialize(email:, secret:, path:)
    @email = email.strip
    @secret = secret
    @path = path
  end

  def call
    check_email
    check_secret

    encode_token if errors.none?
    save_token if errors.none?
    async_email_link if errors.none?
    puts("Errors: #{errors}")
    errors.none?
  end

  def errors
    @errors ||= []
  end

  private

  def check_email
    if !email.present?
      errors << "email address missing"
    elsif !email.match(Devise.email_regexp)
      errors << "email format invalid"
    end
  end

  def check_secret
    errors << "cannot encode without secret" unless secret.present?
  end

  def encode_token
    token_data = {
      exp: (Time.now + TOKEN_DURATION).to_i,
      email: email,
      path: path
    }
    @token = JWT.encode(token_data, secret, "HS256")
  rescue JWT::EncodeError
    errors << "failed to encode JWT token"
  end

  def save_token
    temp_tok = TemporaryUserToken.create(token: @token)
    @shortcode = temp_tok.shortcode
  end

  def async_email_link
    MembershipMailer.login_link(email: email, token: @token, shortcode: @shortcode).deliver_later
  end
end
