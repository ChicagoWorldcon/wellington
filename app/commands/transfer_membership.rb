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

class TransferMembership
  attr_reader :membership, :sender, :receiver

  def initialize(membership, from:, to:)
    @membership = membership
    @sender = from
    @receiver = to
  end

  def call
    transfer_timestamp = Time.now
    old_grant = sender.grants.find_by(membership: membership, active_to: nil)
    old_grant.update!(active_to: transfer_timestamp)
    new_grant = Grant.create!(active_from: transfer_timestamp, membership: membership, user: receiver)
  end
end
