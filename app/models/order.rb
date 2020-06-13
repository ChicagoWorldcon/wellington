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

class Order < ApplicationRecord
  include ActiveScopes

  belongs_to :membership
  belongs_to :reservation

  # There can't be other active orders against the same reservation
  validates :reservation, presence: true, uniqueness: { conditions: -> { active } }, if: :active?

  # Sync when order changes as upgrades can cause users to loose or gain attending rights
  after_commit :sync_with_glue
  def sync_with_glue
    return unless Claim.contact_strategy == ConzealandContact
    return unless ENV["GLUE_BASE_URL"].present?
    user = reservation.user
    return unless user.present?
    GlueSync.perform_async(user.email)
  end
end
