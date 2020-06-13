# frozen_string_literal: true

# Copyright 2019 AJ Esler
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

class Charge < ApplicationRecord
  STATE_FAILED = "failed"
  STATE_SUCCESSFUL = "successful"
  STATE_PENDING = "pending"
  TRANSFER_STRIPE = "stripe"
  TRANSFER_CASH = "cash"

  belongs_to :user
  belongs_to :reservation

  monetize :amount_cents

  validates :amount, presence: true
  validates :comment, presence: true
  validates :state, inclusion: {in: [STATE_FAILED, STATE_SUCCESSFUL, STATE_PENDING]}
  validates :stripe_id, presence: true, if: :stripe?
  validates :transfer, presence: true, inclusion: {in: [TRANSFER_STRIPE, TRANSFER_CASH]}

  scope :stripe, ->() { where(transfer: TRANSFER_STRIPE) }
  scope :cash, ->() { where(transfer: TRANSFER_CASH) }
  scope :pending, ->() { where(state: STATE_PENDING) }
  scope :failed, ->() { where(state: STATE_FAILED) }
  scope :successful, ->() { where(state: STATE_SUCCESSFUL) }

  def stripe?
    transfer == TRANSFER_STRIPE
  end

  def cash?
    transfer == TRANSFER_CASH
  end

  def successful?
    state == STATE_SUCCESSFUL
  end

  def pending?
    state == STATE_PENDING
  end

  def failed?
    state == STATE_FAILED
  end

  # Sync when payments are made as this may mean a user can now attend
  after_commit :sync_with_glue
  def sync_with_glue
    return unless Claim.contact_strategy == ConzealandContact
    return unless ENV["GLUE_BASE_URL"].present?
    return unless successful?
    GlueSync.perform_async(user.email)
  end
end
