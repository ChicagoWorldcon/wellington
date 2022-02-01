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

# User is a login to the members area
# This relies on Devise for handling cookies and sessions and inherits from global config set in config/initializers/devise.rb
# Membership is associated to User through Reservation
# Reservation is associated to user through Claim
# Charge records payment a User makes towards a Reservation
class User < ApplicationRecord
  # Currently this is based on expiring email tokens
  # This avoids lots of people asking for password resets
  # Wouldn't this be cool if we used a passwordless standard like WebAuthn instead - https://webauthn.io/

  devise :trackable

  has_many :active_claims, -> { active }, class_name: "Claim"
  has_many :charges
  has_many :claims
  has_many :notes
  has_many :reservations, through: :active_claims
  has_many :carts

  # See Cart's validations, one active, pending cart and one active, processing cart at a time.
  has_one  :active_pending_cart, -> { active_pending }, class_name: "Cart"
  has_one  :active_processing_cart, -> { active_processing }, class_name: "Cart"

  attribute :email, :canonical_email_address
  attribute :user_provided_email, :string

  def email=(email_address)
    self[:user_provided_email] = email_address
    self[:email] = email_address
  end
  validates :email, presence: true, uniqueness: true
  validates :hugo_download_counter, presence: true

  validate :email_address_format_valid

  scope :in_stripe, -> { where.not(stripe_id: nil) }
  scope :not_in_stripe, -> { where(stripe_id: nil) }

  def in_stripe?
    stripe_id.present?
  end

  def self.find_or_initialize_by_canonical_email(email, &block)
    find_by_email(email) || new(email: email, &block)
  end

  def self.find_or_create_by_canonical_email(email, &block)
    find_by_email(email) || create(email: email, &block)
  end

  def self.find_or_create_by_canonical_email!(email, &block)
    find_by_email(email) || create!(email: email, &block)
  end

  def self.find_by_email(email)
    user   = find_by(user_provided_email: EmailAddress.normal(email))
    user ||= find_by(user_provided_email: email)
    user ||= find_by(email: EmailAddress.normal(email))
    user ||= find_by(email: EmailAddress.canonical(email))
    user
  end

  private

  def email_address_format_valid
    return if email.nil? # covered by presence: true

    errors.add(:email, "is an unsupported format") unless email.match(Devise.email_regexp)

    errors.add(:email, "slashes are unsupported") if email.include?("/")
  end
end
