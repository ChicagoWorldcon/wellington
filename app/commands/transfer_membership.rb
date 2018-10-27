# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
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

# TransferMembership command makes old claims to membership inactive and sets up new claim for receiver
# Truthy return means transfer was successful, otherwise check errors for explanation
class TransferMembership
  attr_reader :membership, :sender, :receiver, :errors

  def initialize(membership, from:, to:)
    @membership = membership
    @sender = from
    @receiver = to
  end

  def call
    @errors = []
    membership.transaction do
      check_membership
      return false if errors.any?

      as_at = Time.now
      old_claim.update!(active_to: as_at)
      receiver.claims.create!(active_from: as_at, membership: membership)
    end
  end

  private

  def check_membership
    if !old_claim.present?
      errors << "membership not held"
      return # bail, avoid leaking information about memberships
    end

    if !old_claim.transferable?
      errors << "claim is not transferable"
    end

    if !membership.transferable?
      errors << "membership is not transferable"
    end
  end

  def old_claim
    @old_claim ||= sender.claims.active.find_by(membership: membership)
  end
end
