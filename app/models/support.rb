# frozen_string_literal: true

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

# Support is not a User, but does present a login means for people who need to access admin pages
# This relies on Devise for handling cookies and sessions and inherits from global config set in config/initializers/devise.rb
# Support actions live on URLs prefixed with /operator
# Support#hugo_admin property exists for sensitive actions that Hugo Admins want exclusive control over, set this to true to alter Nomination forms
# You can use these credentials to sign in through /supports/sign_in
class Support < ApplicationRecord
  # Currently you create Support users thorugh the rails console with Support.create!(email: "...", password: "...")
  # However this can be configured to use Google or Facebook auth instead
  # Please open a MR if you want to do this, and make it configurable plz <3

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable, :omniauthable, :registerable, :recoverable
  devise :database_authenticatable, :rememberable, :validatable, :trackable, :confirmable, :lockable
end
