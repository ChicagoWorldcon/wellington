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
  devise :trackable

  has_many :active_claims, -> { active }, class_name: "Claim"
  has_many :charges
  has_many :claims
  has_many :notes
  has_many :purchases, through: :active_claims

  validates :email, presence: true, uniqueness: true, format: Devise.email_regexp

  scope :in_stripe, -> { where.not(stripe_id: nil) }
  scope :not_in_stripe, -> { where(stripe_id: nil) }

  def in_stripe?
    stripe_id.present?
  end
end
