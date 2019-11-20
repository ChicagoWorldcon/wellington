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
  attr_accessor :categories

  validate :can_nominate

  attr_reader :nominations_by_category

  def can_nominate
    if !reservation.present?
      errors.add(:reservation, "reservation is a required field")
      return
    end

    if !reservation.valid? || !reservation.membership.present?
      errors.add(:reservation, "reservation invalid")
      return
    end

    if reservation.instalment?
      errors.add(:reservation, "reservation isn't paid for yet")
    end

    if reservation.disabled?
      errors.add(:reservation, "reservation is disabled")
    end

    if !reservation.membership.can_vote?
      errors.add(:reservation, "reservation doesn't have voting rights")
    end
  end

  def from_params(params)
    if valid?
      reset_nominations
      record_user_nominations
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
    return false if !@submitted_categories.present?

    # Replace nominations in category with submitted values
    reservation.transaction do
      existing_nominations = reservation.nominations.where(category: @submitted_categories)
      existing_nominations.destroy_all

      submitted_nominations = nominations_by_category.slice(*@submitted_categories).values.flatten
      submitted_nominations.each(&:save) # n.b. Invalid nominations don't save here
    end

    true
  end

  private

  def reset_nominations
    @nominations_by_category = {}.tap do |nominations_by|
      (categories || Category.all.to_a).each do |category|
        nominations_by[category] = []
      end
    end
  end

  def record_user_nominations
    user_nominations.eager_load(:category).find_each do |n|
      nominations_by_category[n.category] << n
    end
  end

  def user_nominations
    if categories.present?
      reservation.nominations.where(category: categories)
    else
      reservation.nominations
    end
  end

  def record_submitted_nominations(params)
    @submitted_categories = []

    (categories || Category.all.to_a).each do |category|
      # Find submitted nominations
      nominations = params.dig("category", category.id.to_s, "nomination")
      next unless nominations

      # Reset and record submitted categories
      @submitted_categories << category
      nominations_by_category[category] = []


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
