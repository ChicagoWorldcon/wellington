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

# Preview all emails at http://localhost:3000/rails/mailers/hugo_mailer
class HugoMailerPreview < ActionMailer::Preview
  def nomination_ballot
    reservation = Reservation.joins(:nominations).sample
    HugoMailer.nomination_ballot(reservation)
  end

  def nominations_notice_dublin
    if params[:user]
      mailer = HugoMailer.nominations_notice_dublin(
        user: User.find_by!(email: params[:user]),
      )
      return mailer
    end

    dublin_users = User.joins(reservations: :membership).where(memberships: {name: :dublin_2019}).distinct
    HugoMailer.nominations_notice_dublin(user: dublin_users.sample)
  end

  def nominations_notice_conzealand
    if params[:user]
      mailer = HugoMailer.nominations_notice_conzealand(
        user: User.find_by!(email: params[:user]),
      )
      return mailer
    end

    users = User.joins(reservations: :membership).merge(Membership.can_nominate).distinct
    conzealand_users = users.where.not(memberships: {name: :dublin_2019})
    HugoMailer.nominations_notice_conzealand(user: conzealand_users.sample)
  end

  def nominations_reminder_2_weeks_left
    if params[:user]
      user = User.find_by!(email: params[:user])
    else
      user = User.all.sample
    end

    HugoMailer.nominations_reminder_2_weeks_left(user: user)
  end

  def nominations_reminder_2_weeks_left_mulit_user
    multi_user = User.joins(:reservations).having("count(reservations.id) > 1").group(:id).sample
    HugoMailer.nominations_reminder_2_weeks_left(user: multi_user)
  end
end
