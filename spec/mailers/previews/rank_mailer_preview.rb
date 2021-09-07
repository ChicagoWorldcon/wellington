# frozen_string_literal: true

# Copyright 2020 Steven Ensslen
# Copyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");

# Preview all emails at http://localhost:3000/rails/mailers/rank_mailer
class RankMailerPreview < ActionMailer::Preview
  def rank_ballot
    reservation = Reservation.joins(:ranks).sample
    RankMailer.rank_ballot(reservation)
  end

  def ranks_open_dc
    if params[:user]
      mailer = RankMailer.ranks_open_dc(
        user: User.find_by!(email: params[:user]),
      )
      return mailer
    end

    users = User.joins(reservations: :membership).merge(Membership.can_vote).distinct
#    dc_users = users.where.not(memberships: {name: :nominate})
    RankMailer.ranks_open_dc(user: users.sample)
  end


  def ranks_open_conzealand
    if params[:user]
      mailer = RankMailer.ranks_open_conzealand(
        user: User.find_by!(email: params[:user]),
      )
      return mailer
    end

    users = User.joins(reservations: :membership).merge(Membership.can_nominate).distinct
    conzealand_users = users.where.not(memberships: {name: :dublin_2019})
    RankMailer.ranks_open_conzealand(user: conzealand_users.sample)
  end

  def ranks_reminder_2_weeks_left_conzealand
    if params[:user]
      user = User.find_by!(email: params[:user])
    else
      user = User.all.sample
    end

    RankMailer.ranks_reminder_2_weeks_left_conzealand(email: user.email)
  end

  def ranks_reminder_2_weeks_left_conzealand_multi_membership
    multi_user = User.joins(:reservations).having("count(reservations.id) > 1").group(:id).sample
    RankMailer.ranks_reminder_2_weeks_left_conzealand(email: multi_user.email)
  end

  def ranks_reminder_3_days_left
    if params[:user]
      user = User.find_by!(email: params[:user])
    else
      user = User.all.joins(:reservations).sample
    end

    RankMailer.ranks_reminder_3_days_left(email: user.email)
  end
end
