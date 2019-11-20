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

class Membership < ApplicationRecord
  include ActiveScopes

  monetize :price_cents

  validates :active_from, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :name, presence: true

  has_many :orders
  has_many :active_orders, -> { active }, class_name: "Order"
  has_many :reservations, through: :active_orders

  scope :order_by_price, -> { order(price_cents: :desc) }

  def to_s
    name.humanize
  end

  # These match i18n values set in config/locales
  def rights
    [].tap do |rights|
      rights << "rights.attend" if can_attend?
      rights << "rights.site_selection" if can_nominate?

      if can_vote?
        rights << "rights.hugo.vote"
        rights << "rights.retro_hugo.vote"
      end

      if can_nominate?
        rights << "rights.hugo.nominate"
        rights << "rights.retro_hugo.nominate"
      end
    end
  end

  # These are rights that may become visible over time, with the possibility of distinguishing between a right that's
  # currently able to be used or one that's coming soon. These also match i18n values in config/locales
  def active_rights
    [].tap do |rights|
      rights << "rights.attend" if can_attend?
      rights << "rights.site_selection" if can_nominate?

      now = DateTime.now

      if now < $nomination_opens_at
        if can_nominate?
          rights << "rights.hugo.nominate_soon"
          rights << "rights.retro_hugo.nominate_soon"
        end
      elsif now.between?($nomination_opens_at, $voting_opens_at)
        if can_nominate? && !can_vote?
          rights << "rights.hugo.nominate_only"
          rights << "rights.retro_hugo.nominate_only"
        elsif can_nominate?
          rights << "rights.hugo.nominate"
          rights << "rights.retro_hugo.nominate"
        end
      elsif now.between?($voting_opens_at, $hugo_closed_at)
        if can_vote?
          rights << "rights.hugo.vote"
          rights << "rights.retro_hugo.vote"
        end
      end
    end
  end
end
