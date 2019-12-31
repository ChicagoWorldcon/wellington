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

class SendBallotSummaries
  include Sidekiq::Worker

  def perform
    job_started_at = Time.now

    User.transaction do
      reservations = ReservationsWithRecentNominations.new.call
      reservations.find_each do |reservation|
        HugoMailer.nomination_ballot(reservation).deliver_now
      end

      affected_users = User.joins(:reservations).where(reservations: {id: reservations})
      affected_users.update_all(ballot_last_mailed_at: job_started_at)
    end
  end
end
