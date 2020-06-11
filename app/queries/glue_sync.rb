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
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def call
    {
      id: user.id.to_s,
      email: user.email,
      name: "",
      display_name: "",
      roles: roles,
    }
  end

  private

  def roles
    if paid_attending_reservations.any?
      ["video"]
    else
      []
    end
  end

  def paid_attending_reservations
    Reservation.paid.joins(:membership).merge(Membership.can_attend)
  end
end
