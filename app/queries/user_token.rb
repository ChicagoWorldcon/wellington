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

# UserToken is a class use for validation and representation of actions on the UserTokensController
# It's useful for form logic and validation
class UserToken
  # Consider reworking this as a devise model based on database_authenticatable

  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :email
  validates :email, presence: true, format: Devise.email_regexp
  before_validation :trim_email

  private

  def trim_email
    @email = @email.strip
  end
end
