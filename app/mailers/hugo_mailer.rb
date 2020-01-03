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

class HugoMailer < ApplicationMailer
  default from: $member_services_email

  def nomination_ballot(reservation)
    @detail = reservation.active_claim.detail
    nominated_categories = Category.joins(nominations: :reservation).where(reservations: {id: reservation})

    builder = MemberNominationsByCategory.new(
      reservation: reservation,
      categories: nominated_categories.order(:order, :id),
    )
    builder.from_reservation
    @nominations_by_category = builder.nominations_by_category

    mail(
      subject: "Your 2020 Hugo and 1945 Retro Hugo Nominations Ballot",
      to: reservation.user.email,
      from: "Hugo Awards 2020 <hugohelp@conzealand.nz>"
    )
  end
end