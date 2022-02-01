# frozen_string_literal: true

# Copyright 2021 Chris Rose
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

# Token::LookupUserByShortcode retrieves a user record by a time-limited short code that we've emailed to them.
class Token::LookupUserByShortcode
  include Rails.application.routes.url_helpers

  attr_reader :shortcode, :secret

  # PATH_LIST contains matches for paths we will allow for client redirect
  # If it's not in this list, then you're going to a default location
  PATH_LIST = [
    "/reservations/new?",
    "/reservations"
  ].freeze

  def initialize(shortcode:, secret:)
    @shortcode = shortcode
    @secret = secret
  end

  def call
    check_shortcode
    check_secret
    return false if errors.any?

    get_token_for_shortcode
    return false if errors.any?

    decode_token
    return false if errors.any?

    lookup_and_validate_user
    return false if errors.any?

    @user
  end

  def errors
    @errors ||= []
  end

  def path
    given_path = @token.first["path"]

    PATH_LIST.each do |legal_path|
      return given_path if given_path.start_with?(legal_path)
    end

    nil
  end

  def cleanup!
    existing = TemporaryUserToken.find_by(shortcode: @shortcode)
    existing.delete if existing
  end

  private

  def check_shortcode
    errors << "missing shortcode" unless shortcode.present?
  end

  def check_secret
    errors << "cannot decode without secret" unless secret.present?
  end

  def get_token_for_shortcode
    stored_token = TemporaryUserToken.find_by(shortcode: shortcode)
    @encoded_token = stored_token&.token
  end

  def decode_token
    @token = JWT.decode(@encoded_token, secret, "HS256")
  rescue JWT::ExpiredSignature
    errors << "token has expired"
  rescue JWT::DecodeError
    errors << "token is malformed"
  end

  def lookup_and_validate_user
    lookup_email = @token.first["email"]&.downcase
    @user = User.find_or_create_by_canonical_email(lookup_email)
    unless @user.valid?
      @user.errors.full_messages.each do |validation_error|
        errors << validation_error
      end
    end
  end
end
