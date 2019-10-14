# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
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

# ListNominations given a reservation will give you objects to list out nominations for a user
class MemberNominationsByCategory
  NOMINATION_KEYS = (1..Nomination::VOTES_PER_CATEGORY).to_a.map(&:to_s)

  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :reservation # Required to instantiate this model

  validate :can_nominate

  attr_reader :nominations_by_category

  def can_nominate
    errors.add(:reservation, "reservation isn't paid for yet") if reservation&.instalment?
    errors.add(:reservation, "reservation is disabled") if reservation&.disabled?
  end

  def from_params(params)
    if valid?
      reset_nominations
      record_submitted_nominations(params)
      add_empties_where_needed
    end

    self
  end

  def from_reservation
    if valid?
      reset_nominations
      record_user_nominations
      add_empties_where_needed
    end

    self
  end

  def save
    return false if !valid?

    valid_nominations = nominations_by_category.values.flatten.select(&:valid?)
    reservation.transaction do
      reservation.nominations.destroy_all
      valid_nominations.map(&:save)
    end

    true
  end

  private

  def reset_nominations
    @nominations_by_category = {}.tap do |nominations_by|
      Category.find_each do |category|
        nominations_by[category] = []
      end
    end
  end

  def record_user_nominations
    reservation.nominations.eager_load(:category).find_each do |n|
      nominations_by_category[n.category] << n
    end
  end

  def record_submitted_nominations(params)
    Category.find_each do |category|
      # Find submitted nominations
      nominations = params.dig("reservation", "category", category.id.to_s, "nomination")
      next unless nominations

      # Pull out up to VOTES_PER_CATEGORY of them, use their description field for a new Nomination
      nominations.slice(*NOMINATION_KEYS).values.each do |nom_params|
        nominations_by_category[category] << Nomination.new(
          reservation: reservation,
          category: category,
          field_1: nom_params["field_1"],
          field_2: nom_params["field_2"],
          field_3: nom_params["field_3"],
        )
      end
    end
  end

  def add_empties_where_needed
    nominations_by_category.keys.each do |category|
      remaining_votes = Nomination::VOTES_PER_CATEGORY - nominations_by_category[category].size

      remaining_votes.times do
        nominations_by_category[category] << Nomination.new(
          category: category,
          reservation: reservation,
        )
      end
    end
  end
end
