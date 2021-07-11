# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
# Copyright 2020 Victoria Garcia
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

# Membership represents present and histircal records for types of membership
# Reservation is associated with a Membership through Order
# User is associated with a Membership through Reservation
# Membership records are displayed for purchase from the MembershipsController when they're 'active'
# Membership may also be associated to a user on import or when a Support user uses the SetMembership class
# Cycling prices means you may have 4 Adult memberships, but it's likely only 1 will be active at a time
# Membership holds rights such as attendance, site selection, nomination and voting
# Membership types that were never available for purchase can be made by setting active_from and active_to to the same time in the past, e.g. dublin_2019
class Membership < ApplicationRecord
  include ActiveScopes
  include Acquirable

  monetize :price_cents

  validates :active_from, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :name, presence: true

  # Date of Birth is required for child and YA memberships
  validates_inclusion_of :dob_required, in: [true, false]

  has_many :cart_items, :as => :acquirable
  has_many :orders
  has_many :active_orders, -> { active }, class_name: "Order"
  has_many :reservations, through: :active_orders

  scope :can_nominate, -> { where(can_nominate: true) }
  scope :can_attend, -> { where(can_attend: true) }
  scope :can_site_select, -> { where(can_site_select: true) }
  scope :can_vote, -> { where(can_vote: true) }

  scope :dob_required, -> { where(dob_required: true) }

  scope :order_by_price, -> { order(price_cents: :desc) }
  scope :with_attend_rights, -> { where(can_attend: true) }
  scope :with_nomination_rights, -> { where(can_nominate: true) }
  scope :with_voting_rights, -> { where(can_vote: true) }

  def to_s
    display_name ? display_name : name.humanize
  end

  # TODO FUTUREWORLDCON Make these rights dynamic in the DB for each membership type
  # n.b. Nomination in 2020 became unavailable to new members once Nomination opened
  # So we created new active Membership records at the same price
  # These match i18n values set in config/locales
  def all_rights
    [].tap do |rights|
      rights << "rights.attend" if can_attend?
      rights << "rights.site_selection" if can_site_select?

      if can_vote?
        rights << "rights.hugo.vote"
      end

      if can_nominate?
        rights << "rights.hugo.nominate"
      end
    end
  end

  def dob_required?
    dob_required
  end

  def display_price_for_cart
    self.price.format(with_currency: true)
  end

  def price_in_cents_for_cart
    self.price_cents
  end

  def name_for_cart
    self.to_s
  end

  def name_and_price_hashcode
    h_price = self.price > 0 ? self.price.format(with_currency: true) : "Free"
    "#{self.name} #{h_price}"
  end

  def price_increase(new_price, start_date, end_date = nil)
    new_record = self.dup
    new_record.price_cents = new_price
    new_record.active_from = start_date.to_time
    new_record.active_to = end_date.present? ? end_date.to_time : nil
    new_record.save

    self.active_to = new_record.active_from
    self.save
  end

end
