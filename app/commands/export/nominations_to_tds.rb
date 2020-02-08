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

# NominationsToTds takes nominations made and pushes them up to Dave's nominations SQL Server setup
class Export::NominationsToTds
  include TdsClient

  def initialize(verbose: false)
    @verbose = verbose
  end

  def call
    return if Nomination.none?

    execute("DELETE FROM External_Nominations_2020")
    nominations_2020.find_in_batches(batch_size: 100) do |batch|
      result = execute(
        %{
          INSERT INTO External_Nominations_2020
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
    end

    execute("DELETE FROM External_Nominations_1945")
    nominations_1945.find_in_batches(batch_size: 100) do |batch|
      result = execute(
        %{
          INSERT INTO External_Nominations_1945
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
    end
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
