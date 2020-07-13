# frozen_string_literal: true
#
# Copyright 2019 Matthew B. Gray
# Copyright 2019 Chris Rose
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

beginning_of_time = "2000-01-01".to_time

PriceGroup = Struct.new("PriceGroup", :start_time, :end_time, :supporting, :adult_attending, :ya, :child, :first_worldcon, :family_1_discount, :family_2_discount, :family_3_discount)
site_selection = "2020-07-30 18:00:00 CST".to_time
price_change_1 = "2021-04-30 23:59:00 CST".to_time
price_change_2 = "2021-11-30 23:59:00 CST".to_time
price_change_3 = "2022-04-30 23:59:00 CST".to_time
at_con = "2022-08-31 23:59:00 CST".to_time


prices = [
  PriceGroup.new(site_selection, price_change_1, Money.new(50_00), Money.new(170_00), Money.new(90_00), Money.new(60_00), Money.new(110_00), Money.new(40_00), Money.new(40_00), Money.new(50_00)),
  PriceGroup.new(price_change_1, price_change_2, Money.new(50_00), Money.new(190_00), Money.new(90_00), Money.new(60_00), Money.new(110_00), Money.new(50_00), Money.new(50_00), Money.new(60_00)),
  PriceGroup.new(price_change_2, price_change_3, Money.new(50_00), Money.new(210_00), Money.new(100_00), Money.new(60_00), Money.new(120_00), Money.new(60_00), Money.new(70_00), Money.new(90_00)),
  PriceGroup.new(price_change_3, at_con,         Money.new(50_00), Money.new(230_00), Money.new(100_00), Money.new(60_00), Money.new(140_00), Money.new(80_00), Money.new(80_00), Money.new(100_00)),
]

########################################################################
# Presupport membership types
Membership.create!(
  name: "Donor",
  price: Money.new(20_00),
  description: "With our thanks!",
  active_from: beginning_of_time,
  active_to: site_selection,
  can_vote: false,
  can_nominate: false,
  can_site_select: false,
  can_attend: false,
)

Membership.create!(
  name: "Friend",
  price: Money.new(150_00),
  description: "Will convert to an attending membership automatically if you vote in tion in 2020",
  active_from: beginning_of_time,
  active_to: site_selection,
  can_vote: false,
  can_nominate: false,
  can_site_select: false,
  can_attend: false,
)

Membership.create!(
  name: "Star",
  price: Money.new(500_00),
  description: "Will convert to an attending membership automatically if you vote in Site Selection in 2020, and something cool for you at the convention! (Shhh…it’s a surprise!)",
  active_from: beginning_of_time,
  active_to: site_selection,
  can_vote: false,
  can_nominate: false,
  can_site_select: false,
  can_attend: false,
)

########################################################################
# Actual Memberships

<<<<<<< HEAD
Membership.create!(
  name: "adult",
  price: Money.new(400_00),
  description: "Full membership for a person who will be physically attending the convention.",
  can_attend: true,
  can_nominate: true,
)

Membership.create!(
  name: "kid_in_tow",
  price: Money.new(50_00),
  description: "Attending membership for a child who will be in the company of their guardian at all times.  Kids-in-tow cannot nominate, vote, or site-select.",
  can_attend: true,
  can_nominate: false,
)

Membership.create!(
  name: "child",
  price: Money.new(100_00),
  description: "Attending membership for a child born after 2007. Child members are allowed to be away from their guardians at times, but cannot nominate, vote, or site-select.",
  can_attend: true,
  can_nominate: false,
)

Membership.create!(
  name: "young_adult",
  price: Money.new(250_00),
  description: "Full, attending membership for a child born after 2002. Young adult members are expected to be on their own at times, and can nominate, vote, and site-select.",
  can_attend: true,
  can_nominate: true,
)

Membership.create!(
  name: "supporting",
  price: Money.new(100_00),
  description: "Voting, nominiating, and site-selecting membership for a person who will not be physically attending the convention.",
  can_attend: false,
  can_nominate: true,
)
=======
prices.each do |price_group|
  Membership.create!(
    name: "Supporting",
    description: "Supporting member of Chicon 8",
    price: price_group.supporting,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: true,
    can_nominate: true,
    can_site_select: true,
    can_attend: false,
  )

  Membership.create!(
    name: "Adult Attending",
    description: "Attending adult member of Chicon 8",
    price: price_group.adult_attending,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: true,
    can_nominate: true,
    can_site_select: true,
    can_attend: true,
  )

  Membership.create!(
    name: "Child (6-15)",
    description: "Attending child member of Chicon 8 (6-15 at-con)",
    price: price_group.child,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: false,
    can_nominate: false,
    can_site_select: false,
    can_attend: true,
  )

  Membership.create!(
    name: "YA (16-25)",
    description: "Attending YA member of Chicon 8 (16-25 at-con)",
    price: price_group.ya,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: true,
    can_nominate: true,
    can_site_select: true,
    can_attend: true,
  )

  Membership.create!(
    name: "First Worldcon",
    description: "Attending their first worldcon",
    price: price_group.first_worldcon,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: true,
    can_nominate: true,
    can_site_select: true,
    can_attend: true,
  )

  Membership.create!(
    name: "Kid-in-Tow",
    description: "A child < 6 years old accompanied by an Adult member",
    price: Money.new(0),
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: false,
    can_nominate: false,
    can_site_select: false,
    can_attend: true,
  )
end
>>>>>>> 50cdb1af04f80b55f30a705290e074470763d7a1

########################################
# Other prod data migrations that happened post deploy

require_relative "development_hugo.seeds.rb"
require_relative "development_dublin.seeds.rb"
require_relative "development_hugo_ordering.seeds.rb"
