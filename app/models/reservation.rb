# frozen_string_literal: true

# Copyright 2019 AJ Esler
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

class Reservation < ApplicationRecord
  PAID = "paid"
  DISABLED = "disabled"
  INSTALMENT = "instalment"

  has_many :charges
  has_many :claims
  has_many :nominations
  has_many :orders

  has_one :active_claim, -> () { active }, class_name: "Claim" # See Claim's validations, one claim active at a time
  has_one :active_order, ->() { active }, class_name: "Order" # See Order's validations, one order active at a time
  has_one :membership, through: :active_order
  has_one :user, through: :active_claim

  validates :membership_number, presence: true, uniqueness: true
  validates :state, presence: true, inclusion: [PAID, INSTALMENT, DISABLED]

  scope :disabled, -> { where(state: DISABLED) }
  scope :instalment, -> { where(state: INSTALMENT) }
  scope :paid, -> { where(state: PAID) }

  def active_rights
    all_held_memberships = Membership.where(id: orders.select(:membership_id))
    all_held_memberships.flat_map(&:active_rights).uniq
  end

  def paid?
    state == PAID
  end

  # Because we don't refund below a supporting membership
  # And because PaymentAmountOptions::MIN_PAYMENT_AMOUNT is equal to a supporting membership
  # We can assume a single successful charge means this membership covers a supporting membership
  def has_paid_supporting?
    charges.successful.any?
  end

  def transferable?
    state != DISABLED
  end

  def instalment?
    state == INSTALMENT
  end

  def disabled?
    state == DISABLED
  end
end
