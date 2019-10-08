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
  VOTES_PER_CATEGORY = 5
  NOMINATION_KEYS = (1..VOTES_PER_CATEGORY).to_a.map(&:to_s)

  include ActiveModel::Model
  attr_accessor :reservation # Required to instantiate this model

  attr_reader :nominations_by_category

  def from_params(params)
    reset_nominations

    Category.find_each do |category|
      # Find submitted nominations
      nominations = params.dig("reservation", "category", category.id.to_s, "nomination")
      next unless nominations

      # Pull out up to VOTES_PER_CATEGORY of them, use their description field for a new Nomination
      nominations.slice(*NOMINATION_KEYS).values.each do |nom_params|
        nominations_by_category[category] << Nomination.new(
          reservation: reservation,
          category: category,
          description: nom_params["description"],
        )
      end
    end
  end

  def call
    reset_nominations

    check_reservation
    return false if errors.any?

    sort_existing_nominations
    add_empties_where_needed
    nominations_by_category
  end

  def errors
    @errors ||= []
  end

  private

  def check_reservation
    errors << "reservation isn't paid for yet" if reservation.instalment?
    errors << "reservation is disabled" if reservation.disabled?
  end

  def reset_nominations
    @nominations_by_category = {}.tap do |nominations_by|
      Category.find_each do |category|
        nominations_by[category] = []
      end
    end
  end

  def sort_existing_nominations
    reservation.nominations.eager_load(:category).find_each do |n|
      nominations_by_category[n.category] << n
    end
  end

  def add_empties_where_needed
    nominations_by_category.keys.each do |category|
      remaining_votes = VOTES_PER_CATEGORY - nominations_by_category[category].size

      remaining_votes.times do
        nominations_by_category[category] << Nomination.new(
          category: category,
          reservation: reservation,
        )
      end
    end
  end
end
