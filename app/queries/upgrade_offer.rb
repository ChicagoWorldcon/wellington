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

# UpgradeOffer is used for a User who is trying to upgrade between different membership types
# This price is the difference between what the user has paid, and the Membership they're trying to set
# e.g.
# Silver Fern upgrading to Adult cost $50 on CoNZealand launch ($375 - $325 = $50)
# But when prices rotated, upgrading to Adult cost $75 ($400 - $325 = $75)
class UpgradeOffer
  attr_reader :from_membership, :to_membership

  delegate :description, to: :to_membership

  def self.from(current_membership, target_membership: nil, for_reservation: nil)

    # Get all the active options with a higher price than the current membership
    options = Membership.active.where("price_cents > ?", current_membership.price_cents)
    initial_count = options.count

    # Combine in any earlier (cheaper) Memberships the reservation holder has
    # locked in.
    options = self.include_locked_in_options(current_membership, for_reservation, options)

    # We typically order by price, but if there are multiple price-points for
    # a particular membership due to older prices being locked in, that can be
    # confusing, and ordering by name is better.
    order_pricewise = (initial_count <= options.count)

    # Don't duplicate the current membership, i.e. no offering to upgrade adult to adult
    options = options.where.not(name: current_membership.name)

    # If requested, only create offers for the target
    options = options.where(id: target_membership) if target_membership.present?

    order_pricewise ? self.order_options_by_price(options, current_membership) : self.order_options_by_name(options, current_membership)
  end

  def self.include_locked_in_options(curr_membership, res_to_upgrade, existing_options)
    unless (res_to_upgrade.present? && res_to_upgrade.date_upgrade_prices_locked.respond_to?(:strftime) )
      return existing_options
    end

    locked_in_options = Membership.active_at(res_to_upgrade.date_of_price_lock).where("price_cents > ?", curr_membership.price_cents)

    existing_options.or(locked_in_options)
  end

  def self.order_options_by_name(our_options, curr_membership)
    our_options.order_by_name.map do |membership|
      UpgradeOffer.new(from: curr_membership, to: membership)
    end
  end

  def self.order_options_by_price(our_options, curr_membership)
    our_options.order_by_price.map do |membership|
      UpgradeOffer.new(from: curr_membership, to: membership)
    end
  end

  def initialize(from:, to:)
    @from_membership = from
    @to_membership = to
  end

  def to_s
    "Upgrade to #{to_membership} (#{formatted_price})"
  end

  def hash
    "#{to_membership} #{formatted_price}"
  end

  def link_text
    "Upgrade to #{to_membership}"
  end

  def name
    "Upgrade to #{to_membership}"
  end

  def membership_rights
    to_membership.all_rights
  end

  def link_description
    if to_membership.description.present?
      "#{to_membership.description}, for #{formatted_price}"
    else
      "for #{formatted_price}"
    end
  end

  def confirm_text
    "This will upgrade your membership to #{to_membership} at a cost of #{formatted_price}. Are you sure?"
  end

  def formatted_price
    price.format(with_currency: true)
  end

  def price
    @price ||= to_membership.price - from_membership.price
  end

  def offer_for_purchase?
    !to_membership.private_membership_option
  end
end
