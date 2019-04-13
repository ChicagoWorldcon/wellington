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

class Charge < ApplicationRecord
  STATE_FAILED = "failed"
  STATE_SUCCESSFUL = "successful"
  STATE_PENDING = "pending"
  TRANSFER_STRIPE = "stripe"
  TRANSFER_CASH = "cash"

  belongs_to :user
  belongs_to :purchase

  validates :amount, presence: true
  validates :comment, presence: true
  validates :state, inclusion: {in: [STATE_FAILED, STATE_SUCCESSFUL, STATE_PENDING]}
  validates :stripe_id, presence: true, if: :stripe_transfer?
  validates :transfer, presence: true, inclusion: {in: [TRANSFER_STRIPE, TRANSFER_CASH]}

  scope :stripe, ->() { where(transfer: TRANSFER_STRIPE) }
  scope :cash, ->() { where(transfer: TRANSFER_CASH) }
  scope :pending, ->() { where(state: STATE_PENDING) }
  scope :failed, ->() { where(state: STATE_FAILED) }
  scope :successful, ->() { where(state: STATE_SUCCESSFUL) }

  def stripe_transfer?
    transfer == TRANSFER_STRIPE
  end

  def successful?
    state == STATE_SUCCESSFUL
  end

  def pending?
    state == STATE_PENDING
  end
end
