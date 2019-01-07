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
  include ActiveModel::Model

  attr_accessor :email
  attr_accessor :secret

  validates :email, presence: true, format: Devise.email_regexp
  validates :secret, presence: true

  def login_token(secret)
    User.new(email: email).login_token(secret)
  end

  def self.lookup_token!(secret, jwt_token:)
    User.lookup_token!(secret, jwt_token: jwt_token)
  end
end
