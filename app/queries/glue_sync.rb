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

# GlueSync takes a user and gives you the information you need to sync to
# Glue for the Virtual Worldcon in 2020
class GlueSync
  attr_reader :user, :remote_user

  def initialize(user, remote_user: {})
    @user = user
    @remote_user = remote_user
  end

  def call
    {
      id: user.id.to_s,
      email: user.email,
      roles: roles,
      name: preferred_contact.to_s,
      display_name: preferred_contact.badge_display,
    }
  end

  private

  def roles
    roles = remote_user[:roles]
    roles = [] unless roles.kind_of?(Array)

    if my_attending_reservations.any?
      roles << "video"
    else
      roles.delete("video")
    end

    roles.uniq
  end

  def preferred_contact
    return @preferred_contact if @preferred_contact.present?

    contacts = ConzealandContact.joins(claim: :reservation)
    my_attending_contacts = contacts.where(reservations: { id: my_attending_reservations })
    earliest_contact = my_attending_contacts.order("reservations.created_at").first
    @preferred_contact = earliest_contact || ConzealandContact.new
  end

  def my_attending_reservations
    my_reservations = Reservation.paid.joins(:membership, :user).where(users: {id: user})
    my_reservations.merge(Membership.can_attend).merge(Claim.active)
  end
end
