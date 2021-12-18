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
  has_one  :active_pending_cart, -> () { active_pending }, class_name: "Cart"
  has_one  :active_processing_cart, -> () { active_processing }, class_name: "Cart"
  has_one :offer_lock_date, required: false


  validates :email, presence: true, uniqueness: true
  validates :hugo_download_counter, presence: true

  validate :email_address_format_valid

  scope :in_stripe, -> { where.not(stripe_id: nil) }
  scope :not_in_stripe, -> { where(stripe_id: nil) }

  def in_stripe?
    stripe_id.present?
  end

  def lock_offer
    offer_lock_date = Time.now unless offer_lock_date.present?
  end

  def date_offer_locked
    return -1 unless offer_lock_date.present?
    offer_lock_date
  end

  def offer_locked?
    return false unless offer_lock_date.present?
    true
  end

  private

  def email_address_format_valid
    return if email.nil? # covered by presence: true

    if !email.match(Devise.email_regexp)
      errors.add(:email, "is an unsupported format")
    end

    if email.include?("/")
      errors.add(:email, "slashes are unsupported")
    end
  end
end
