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

# ReservationsWithRecentNominations returns a list of reservations who need to be sent nomination summaries
class ReservationsWithRecentNominations
  MINIMUM_WAIT = 10.minutes

  def call
    reservations_with_updates.distinct.where.not(id: reservations_with_recent_activity.select(:id))
  end

  private

  def reservations_with_recent_activity
    reservations.where("nominations.created_at > ?", MINIMUM_WAIT.ago)
  end

  def reservations_with_updates
    reservations.where(%{
      reservations.ballot_last_mailed_at IS NULL                     -- User has never been mailed their ballot
      OR nominations.created_at > reservations.ballot_last_mailed_at -- Or user has made nomination since their last mail
    })
  end

  def reservations
    Reservation.joins(:nominations)
  end
end
