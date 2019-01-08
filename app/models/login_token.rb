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

# Token is an ActiveModel and isn't stored but is rather used to represent token based authentication
# See https://guides.rubyonrails.org/active_model_basics.html
# TODO Consider reworking this as a devise model based on database_authenticatable
class LoginToken
  TOKEN_DURATION = 10.minutes

  include ActiveModel::Model

  attr_accessor :email
  attr_accessor :secret

  validates :email, presence: true, format: Devise.email_regexp
  validates :secret, presence: true

  def self.decode_and_lookup!(secret, jwt_token:)
    self.decode(secret: secret, token: jwt_token).user
  end

  def self.decode(secret:, token:)
    login_info = JWT.decode(token, secret, "HS256")
    LoginToken.new(secret: secret, email: login_info.first["email"])
  end

  def encode
    JWT.encode(login_info, secret, "HS256")
  end

  def user
    User.find_by(email: email)
  end

  def login_info
    {
      exp: (Time.now + TOKEN_DURATION).to_i,
      email: email,
    }
  end
end
