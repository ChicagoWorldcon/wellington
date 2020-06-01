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

# ListVoting given a reservation will give you objects to list out votes for a user
class MemberVotingByCategory
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :reservation # Required to instantiate this model
  attr_accessor :categories

  validates :reservation, presence: true
  validates :categories, presence: true

  validate :can_vote

  attr_reader :votes_by_category

  def can_vote
    if !reservation.present?
      errors.add(:reservation, "is a required field")
      return
    end

    if !reservation.valid? || !reservation.membership.present?
      errors.add(:reservation, "invalid")
      return
    end

    if !reservation.paid? && !reservation.has_paid_supporting?
      errors.add(:reservation, "isn't paid for yet")
    end

    if reservation.disabled?
      errors.add(:reservation, "does not have voting rights, contact hugohelp@conzealand.nz if assistance is needed")
    end

    if !reservation.can_vote?
      errors.add(:reservation, "does not have voting rights")
    end
  end

  def from_params(params)
    if valid?
      reset_votes
      record_user_votes
      record_submitted_votes(params)
    end

    self
  end

  def from_reservation
    if valid?
      reset_votes
      record_user_votes
    end

    self
  end

  def save
    return false if !valid?
    return false if !@submitted_categories.present?

    # Replace votes in category with submitted values
    reservation.transaction do
      existing_votes = reservation.votes.where(category: @submitted_categories)
      existing_votes.destroy_all

      votes_by_category.slice(*@submitted_categories).each do |category, votes|
        # n.b. blank votes don't save as they're not valid
        votes.last(Election::VOTES_PER_CATEGORY).each(&:save)
      end
    end

    true
  end

  def error_message
    errors.full_messages.to_sentence
  end

  private

  def reset_votes
    @votes_by_category = {}.tap do |votes_by|
      categories.each do |category|
        votes_by[category] = []
      end
    end
  end

  def record_user_votes
    user_votes.eager_load(:category).find_each do |n|
      votes_by_category[n.category] << n
    end
  end

  def user_votes
    reservation.ranks.where(category: categories)
  end

  def record_submitted_votes(params)
    @submitted_categories = []

    categories.each do |category|
      # Find submitted votes
      votes = params.dig("category", category.id.to_s, "finalists")
      next unless votes

      # Reset and record submitted categories
      @submitted_categories << category
      votes_by_category[category] = []


      # Pull out up to VOTES_PER_CATEGORY of them, use their description field for a new Nomination
      votes.slice(*VOTING_KEYS).values.each do |nom_params|
        votes_by_category[category] << Rank.new(
          reservation: reservation,
          category: category,
          rank: params["rank"]
        )
      end
    end
  end
end
