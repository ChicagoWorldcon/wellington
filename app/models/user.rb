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

class User < ApplicationRecord
  has_many :active_claims, -> { active }, class_name: "Claim"
  has_many :charges
  has_many :claims
  has_many :notes
  has_many :purchases, through: :active_claims

  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

  def login_token(secret)
    JWT.encode(login_info, secret, "HS256")
  end

  def self.lookup_token!(secret, jwt_token:)
    login_info = JWT.decode(jwt_token, secret, "HS256")
    User.find_by(email: login_info.first["email"])
  end

  def login_info
    {
      exp: 1.hour.from_now.to_i,
      email: email,
    }
  end
end
