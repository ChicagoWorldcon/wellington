# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 Jen Zajac (jenofdoom)
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

# MembershipOffer is a representation of how to display a price of a Membership to a User
# MembershipOffer#options generates what's displayed in the shop based on Membership#active records
# MembershipOffer is used in ReservationsController to display prices, but also to check if an offer is available
# see also SetMembership
class MembershipOffer
  attr_reader :membership

  delegate :description, to: :membership

  def self.options
    Membership.active.order_by_price.map do |membership|
      MembershipOffer.new(membership)
    end
  end

  def initialize(membership)
    @membership = membership
  end

  def to_s
    "#{membership} #{formatted_price}"
  end

  # Compute a hash-code for this hash. Two offers with the same content will have the same hash code.
  def hash
    "#{membership} #{formatted_price}"
  end

  def formatted_price
    if membership.price > 0
      membership.price.format(with_currency: true)
    else
      "Free"
    end
  end

  def name
    "#{membership}"
  end

  def can_attend?
    membership.can_attend
  end

  def membership_rights
    membership.all_rights
  end

  def dob_required?
    membership.dob_required?
  end
end
