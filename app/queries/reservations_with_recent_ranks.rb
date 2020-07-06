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

# ReservationsWithRecentRanks returns a list of reservations who need to be sent rank summaries
# It's used by SendRankSummaries to get a shortlist of Reservation records that need to have an email sent out
class ReservationsWithRecentRanks
  MINIMUM_WAIT = 10.minutes

  def call
    reservations_with_updates.distinct.where.not(id: reservations_with_recent_activity.select(:id))
  end

  private

  def reservations_with_recent_activity
    reservations.where("ranks.created_at > ?", MINIMUM_WAIT.ago)
  end

  def reservations_with_updates
    reservations.where(%{
      reservations.ballot_last_mailed_at IS NULL               -- User has never been mailed their ballot
      OR ranks.created_at > reservations.ballot_last_mailed_at -- Or user has made rank since their last mail
    })
  end

  def reservations
    Reservation.joins(:ranks)
  end
end
