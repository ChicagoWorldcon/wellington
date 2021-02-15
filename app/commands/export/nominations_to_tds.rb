# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
# Copyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# 15-Feb-21 FNB Update table year values, remove Retro code

# Export::NominationsToTds puts categories stored in our system and syncs them with Dave's SQL Server setup
# This SQL Server backs admin for the Hugo Nominations
class Export::NominationsToTds
  include ::Export::TdsClient

  def initialize(verbose: false)
    @verbose = verbose
  end

  def call
    return if Nomination.none?

    execute("DELETE FROM External_Nominations_2021").do
    nominations_2020.find_in_batches(batch_size: 100) do |batch|
      result = execute(
        %{
          INSERT INTO External_Nominations_2021
            (NominatorID, NominationID, CategoryID, PrimaryData, SecondData, ThirdData)
          VALUES
            #{batch.size.times.map { "( %i, %i, %i, '%s', '%s', '%s' )" }.join(",")}
          ;
        },
        batch.flat_map do |nomination|
          [
            nomination.reservation.membership_number,
            nomination.id,
            nomination.category.id,
            nomination.field_1,
            nomination.field_2,
            nomination.field_3,
          ]
        end
      )
      puts result.insert
      result.do # trerminate it.
    end

#    execute("DELETE FROM External_Nominations_1945")
#    nominations_1945.find_in_batches(batch_size: 100) do |batch|
#       result = execute(
#         %{
#           INSERT INTO External_Nominations_1945
#             (NominatorID, NominationID, CategoryID, PrimaryData, SecondData, ThirdData)
#           VALUES
#             #{batch.size.times.map { "( %i, %i, %i, '%s', '%s', '%s' )" }.join(",")}
#           ;
#         },
#         batch.flat_map do |nomination|
#           [
#             nomination.reservation.membership_number,
#             nomination.id,
#             nomination.category.id,
#             nomination.field_1,
#             nomination.field_2,
#             nomination.field_3,
#           ]
#         end
#       )
#       puts result.insert
#     end
   end

  private

  def nominations_2020
    active_nominations.where(elections: {i18n_key: "hugo"})
  end

  def nominations_1945
    active_nominations.where(elections: {i18n_key: "retro_hugo"})
  end

  def active_nominations
    nominations = Nomination.joins(category: :election, reservation: :user).eager_load(:category, :reservation)
    nominations.where.not(reservations: {state: Reservation::DISABLED})
  end
end
