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

# UpgradeOffer holds information about a membership upgrade at a price
class UpgradeOffer
  attr_reader :from_membership, :to_membership

  delegate :description, to: :to_membership

  def self.from(current_membership, target_membership: nil)
    # List options that are higher price
    options = Membership.active.where("price_cents > ?", current_membership.price_cents)

    # But don't let the name match, i.e. no upgrade adult to adult upgrade option
    options = options.where.not(name: current_membership.name)

    # If requested, only create offers for the target
    options = options.where(id: target_membership) if target_membership.present?

    # Map matching memberships over the class and return as a list
    options.order_by_price.map do |membership|
      UpgradeOffer.new(from: current_membership, to: membership)
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
end
