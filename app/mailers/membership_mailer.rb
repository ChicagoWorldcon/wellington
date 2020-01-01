# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 Steven C Hartley
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

class MembershipMailer < ApplicationMailer
  default from: $member_services_email

  def login_link(token:, email:)
    @token = token
    mail(
      to: email,
      subject: "CoNZealand Login Link for #{email}"
    )
  end

  def transfer(from:, to:, owner_name:, membership_number:)
    @from = from
    @to = to
    @owner_name = owner_name
    @membership_number = membership_number

    mail(
      to: [from, to],
      cc: $member_services_email,
      subject: "CoNZealand: Transferred ##{membership_number} from #{from} to #{to}"
    )
  end

  def nominations_notice_dublin(user:)
    @user = user
    @reservations = user.reservations.joins(:membership).where(memberships: {name: :dublin_2019})

    @account_numbers = @reservations.pluck(:membership_number).map { |n| "##{n}" }
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

    numbers = @reservations.pluck(:membership_number).map { |n| "##{n}" }
    if numbers.count == 1
      subject = "CoNZealand: Hugo Nominations are now open for member #{numbers.first}"
    else
      subject = "CoNZealand: Hugo Nominations are now open for members #{numbers.to_sentence}"
    end

    mail(to: user.email, from: "hugohelp@conzealand.nz", subject: subject)
  end
end
