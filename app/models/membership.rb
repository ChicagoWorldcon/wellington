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

class Membership < ApplicationRecord
  include ActiveScopes

  monetize :price_cents

  validates :active_from, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :name, presence: true

  has_many :orders
  has_many :active_orders, -> { active }, class_name: "Order"
  has_many :reservations, through: :active_orders

  scope :can_nominate, -> { where(can_nominate: true) }
  scope :can_attend, -> { where(can_attend: true) }
  scope :can_site_select, -> { where(can_site_select: true) }
  scope :can_vote, -> { where(can_vote: true) }

  scope :order_by_price, -> { order(price_cents: :desc) }
  scope :with_attend_rights, -> { where(can_attend: true) }
  scope :with_nomination_rights, -> { where(can_nominate: true) }
  scope :with_voting_rights, -> { where(can_vote: true) }

  def to_s
    name.humanize
  end

  # These match i18n values set in config/locales
  def all_rights
    [].tap do |rights|
      rights << "rights.attend" if can_attend?
      rights << "rights.site_selection" if can_site_select?

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
end
