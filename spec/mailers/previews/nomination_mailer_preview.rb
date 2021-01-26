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

# Preview all emails at http://localhost:3000/rails/mailers/nomination_mailer
class NominationMailerPreview < ActionMailer::Preview
  def nomination_ballot
    reservation = Reservation.joins(:nominations).sample
    NominationMailer.nomination_ballot(reservation)
  end

  def nominations_open_dublin
    if params[:user]
      mailer = NominationMailer.nominations_open_dublin(
        user: User.find_by!(email: params[:user]),
      )
      return mailer
    end

    dublin_users = User.joins(reservations: :membership).where(memberships: {name: :dublin_2019}).distinct
    NominationMailer.nominations_open_dublin(user: dublin_users.sample)
  end

  def nominations_open_conzealand
    if params[:user]
      mailer = NominationMailer.nominations_open_conzealand(
        user: User.find_by!(email: params[:user]),
      )
      return mailer
    end

    users = User.joins(reservations: :membership).merge(Membership.can_nominate).distinct
    conzealand_users = users.where.not(memberships: {name: :dublin_2019})
    NominationMailer.nominations_open_conzealand(user: conzealand_users.sample)
  end

  def nominations_open_dc
    if params[:user]
      mailer = NominationMailer.nominations_open_dc(
        user: User.find_by!(email: params[:user]),
      )
      return mailer
    end

    users = User.joins(reservations: :membership).merge(Membership.can_nominate).distinct
    conzealand_users = users.where.not(memberships: {name: :dublin_2019})
    NominationMailer.nominations_open_dc(user: conzealand_users.sample)
  end


  def nominations_open_chicago
    # TODO- MAKE SURE THIS WORKS
    if params[:user]
      mailer = NominationMailer.nominations_open_chicago(
        user: User.find_by!(email: params[:user]),
      )
      return mailer
    end
    users = User.joins(reservations: :membership).merge(Membership.can_nominate).distinct
    chicago_users = # TODO-- WRITE THIS QUERY.
    NominationMailer.nominations_open_chicago(user: chicago_users.sample)
  end

  def nominations_reminder_2_weeks_left_chicago
    # TODO- MAKE SURE THIS WORKS
    if params[:user]
      user = User.find_by!(email: params[:user])
    else
      user = User.all.sample
    end

    NominationMailer.nominations_reminder_2_weeks_left_chicago(email: user.email)
  end

  def nominations_reminder_2_weeks_left_conzealand
    if params[:user]
      user = User.find_by!(email: params[:user])
    else
      user = User.all.sample
    end

    NominationMailer.nominations_reminder_2_weeks_left_conzealand(email: user.email)
  end

  def nominations_reminder_2_weeks_left_dublin
    if params[:user]
      user = User.find_by!(email: params[:user])
    else
      user = User.all.sample
    end

    NominationMailer.nominations_reminder_2_weeks_left_dublin(email: user.email)
  end

  def nominations_reminder_2_weeks_left_conzealand_multi_membership
    multi_user = User.joins(:reservations).having("count(reservations.id) > 1").group(:id).sample
    NominationMailer.nominations_reminder_2_weeks_left_conzealand(email: multi_user.email)
  end

  def nominations_reminder_2_weeks_left_chicago_multi_membership
    # TODO: Make sure this will work for Chicago.
    multi_user = User.joins(:reservations).having("count(reservations.id) > 1").group(:id).sample
    NominationMailer.nominations_reminder_2_weeks_left_chicago(email: multi_user.email)
  end

  def nominations_reminder_3_days_left
    # TODO:  Make sure this will work for Chicago
    if params[:user]
      user = User.find_by!(email: params[:user])
    else
      user = User.all.joins(:reservations).sample
    end

    NominationMailer.nominations_reminder_3_days_left(email: user.email)
  end
end
