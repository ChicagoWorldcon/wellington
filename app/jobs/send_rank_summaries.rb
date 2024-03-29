# frozen_string_literal: true

# Copyright 2020 Steven Ensslen
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

# SendRankSummaries exists to tell a User when they've made Rank records so they can be sure they've been saved
# This is only sent when a User has a Rank where it's #created_at is 10-30 mins older than Reservation#ballot_last_mailed_at
class SendRankSummaries
  include Sidekiq::Worker

  def perform
    # By taking down the time at the start,
    # we can make sure that any ranks made while this was run will get picked up in the next run
    job_started_at = Time.now

    User.transaction do
      reservations = ReservationsWithRecentRanks.new.call
      reservations.find_each do |reservation|
        RankMailer.rank_ballot(reservation).deliver_now
      rescue StandardError
        puts "Unable to send the ballot update for #{reservation.active_claim.contact.hugo_name}"
      end

      reservations.update_all(ballot_last_mailed_at: job_started_at)
    end
  end
end
