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

  def nominations_notice_dublin(user:)
    @user = user
    @reservations = user.reservations.joins(:membership).where(memberships: {name: :dublin_2019})

    @account_numbers = account_numbers_from(@reservations)
    if @account_numbers.count == 1
      subject = "CoNZealand: Hugo Nominations are now open for account #{@account_numbers.first}"
    else
      subject = "CoNZealand: Hugo Nominations are now open for accounts #{@account_numbers.to_sentence}"
    end

    mail(to: user.email, from: "hugohelp@conzealand.nz", subject: subject)
  end

  def nominations_notice_conzealand(user:)
    @user = user
    @reservations = user.reservations.joins(:membership).merge(Membership.can_nominate)

    account_numbers = account_numbers_from(@reservations)
    if account_numbers.count == 1
      subject = "CoNZealand: Hugo Nominations are now open for member #{account_numbers.first}"
    else
      subject = "CoNZealand: Hugo Nominations are now open for members #{account_numbers.to_sentence}"
    end

    mail(to: user.email, from: "hugohelp@conzealand.nz", subject: subject)
  end

  def nominations_reminder_2_weeks_left_conzealand(user:)
    reservations_that_can_nominate = user.reservations.joins(:membership).merge(Membership.can_nominate)

    if reservations_that_can_nominate.none?
      return
    end

    account_numbers = account_numbers_from(reservations_that_can_nominate)
    if account_numbers.count == 1
      subject = "2 weeks to go! Hugo Award Nominating Reminder for member #{account_numbers.first}"
    else
      subject = "2 weeks to go! Hugo Award Nominating Reminder for members #{account_numbers.to_sentence}"
    end

    @details = Detail.where(claim_id: user.active_claims)

    mail(to: user.email, from: "hugohelp@conzealand.nz", subject: subject)
  end

  def nominations_reminder_2_weeks_left_dublin(user:)
    reservations_that_can_nominate = user.reservations.joins(:membership).merge(Membership.can_nominate)

    if reservations_that_can_nominate.none?
      return
    end

    account_numbers = account_numbers_from(reservations_that_can_nominate)
    if account_numbers.count == 1
      subject = "2 weeks to go! Hugo Award Nominating Reminder for account #{account_numbers.first}"
    else
      subject = "2 weeks to go! Hugo Award Nominating Reminder for accounts #{account_numbers.to_sentence}"
    end

    @details = Detail.where(claim_id: user.active_claims)

    mail(to: user.email, from: "hugohelp@conzealand.nz", subject: subject)
  end

  private

  # Given reservations, gets membership numbers and puts a pound in front of each
  def account_numbers_from(reservations)
    reservations.pluck(:membership_number).map { |n| "##{n}" }
  end
end
