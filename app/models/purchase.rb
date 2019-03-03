# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
# Copyright 2019 AJ Esler
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

class Purchase < ApplicationRecord
  PAID = "paid"
  DISABLED = "disabled"
  INSTALLMENT = "installment"

  has_many :charges
  has_many :claims
  has_many :orders

  has_one :active_claim, -> () { active }, class_name: "Claim" # See Claim's validations, one claim active at a time
  has_one :active_order, ->() { active }, class_name: "Order" # See Order's validations, one order active at a time
  has_one :membership, through: :active_order
  has_one :user, through: :active_claim

  validates :membership_number, presence: true, uniqueness: true
  validates :state, presence: true, inclusion: [PAID, INSTALLMENT, DISABLED]

  scope :disabled, -> { where(state: DISABLED) }
  scope :installment, -> { where(state: INSTALLMENT) }
  scope :paid, -> { where(state: PAID) }

  def paid?
    state == PAID
  end

  def transferable?
    state == PAID
  end
end
