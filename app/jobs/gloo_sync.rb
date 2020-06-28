# Copyright 2020 Matthew B. Gray
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

require "net/http"

# GlooSync sends user data to Gloo so they can log in for the virtual worldcon in 2020
class GlooSync
  include Sidekiq::Worker

  def self.all_users
    User.find_each do |user|
      perform_async(user.email)
    end
  end

  # FIXME there are interfaces here that are non existant and non tested
  def perform(email, roles = [])
    user = User.find_by!(email: email)

    syncable_reservations = Reservation.paid
      .joins(:membership, :user)
      .where(users: {id: user})
      .merge(Membership.with_rights)
      .merge(Claim.active)

    earliest_reservation = syncable_reservations.order("reservations.created_at").first

    contact = GlooContact.new(earliest_reservation)
    contact.set_remote_roles(roles)
    contact.save!
  end
end
