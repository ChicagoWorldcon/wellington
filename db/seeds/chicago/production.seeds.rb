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

PriceGroup = Struct.new("PriceGroup", :start_time, :end_time, :supporting, :adult, :ya, :teen, :child, :first_worldcon, keyword_init: true)
site_selection = "2020-07-28 18:00:00 CST".to_time
site_announcement = "2020-07-30 18:00:00 CST".to_time
price_change_1 = "2021-04-30 23:59:00 CST".to_time
price_change_2 = "2021-11-30 23:59:00 CST".to_time
price_change_3 = "2022-04-30 23:59:00 CST".to_time
at_con = "2022-08-31 23:59:00 CST".to_time


launch_pricing = PriceGroup.new(
  start_time: site_announcement - 10.days,
  end_time: price_change_1,
  supporting: Money.new(50_00),
  adult: Money.new(170_00),
  ya: Money.new(90_00),
  teen: Money.new(70_00),
  child: Money.new(50_00),
  first_worldcon: Money.new(110_00)
)

########################################################################
# Presupport membership types
Membership.create!(
  name: "donor",
  display_name: "Donor",
  price: Money.new(20_00),
  description: "With our thanks!",
  active_from: beginning_of_time,
  active_to: site_selection,
  can_vote: false,
  can_nominate: false,
  can_site_select: false,
  can_attend: false,
  dob_required: false,
)

Membership.create!(
  name: "friend",
  display_name: "Friend",
  price: Money.new(150_00),
  description: "Will convert to an attending membership automatically if you vote in Site Selection in 2020",
  active_from: beginning_of_time,
  active_to: site_selection,
  can_vote: false,
  can_nominate: false,
  can_site_select: false,
  can_attend: false,
  dob_required: false,
)

Membership.create!(
  name: "star",
  display_name: "Star",
  price: Money.new(500_00),
  description: "Will convert to an attending membership automatically if you vote in Site Selection in 2020, and something cool for you at the convention! (Shhh…it’s a surprise!)",
  active_from: beginning_of_time,
  active_to: site_selection,
  can_vote: false,
  can_nominate: false,
  can_site_select: false,
  can_attend: false,
  dob_required: false,
)

def create_price_group!(price_group)
  Membership.create!(
    name: "supporting",
    display_name: "Supporting",
    description: "Supporting member of Chicon 8",
    price: price_group.supporting,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: true,
    can_nominate: true,
    can_site_select: true,
    can_attend: false,
    dob_required: false,
  )

  Membership.create!(
    name: "adult",
    display_name: "Adult Attending",
    description: "Attending adult member of Chicon 8",
    price: price_group.adult,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: true,
    can_nominate: true,
    can_site_select: true,
    can_attend: true,
    dob_required: false,
  )

  Membership.create!(
    name: "child",
    display_name: "Child (10-13)",
    description: "Attending child member of Chicon 8 (10-13 at-con)",
    price: price_group.child,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: false,
    can_nominate: false,
    can_site_select: false,
    can_attend: true,
    dob_required: true,
  )

  Membership.create!(
    name: "teen",
    display_name: "Teen (14-17)",
    description: "Attending teen member of Chicon 8 (14-17 at-con)",
    price: price_group.child,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: false,
    can_nominate: false,
    can_site_select: false,
    can_attend: true,
    dob_required: true,
  )

  Membership.create!(
    name: "ya",
    display_name: "YA (18-24)",
    description: "Attending YA member of Chicon 8 (18-24 at-con)",
    price: price_group.ya,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: true,
    can_nominate: true,
    can_site_select: true,
    can_attend: true,
    dob_required: true,
  )

  Membership.create!(
    name: "first",
    display_name: "First Worldcon",
    description: "Attending their first worldcon",
    price: price_group.first_worldcon,
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: true,
    can_nominate: true,
    can_site_select: true,
    can_attend: true,
    dob_required: false,
  )

  Membership.create!(
    name: "kidit",
    display_name: "Kid-in-Tow (0-9)",
    description: "A child < 10 years old accompanied by an Adult member",
    price: Money.new(0),
    active_from: price_group.start_time,
    active_to: price_group.end_time,
    can_vote: false,
    can_nominate: false,
    can_site_select: false,
    can_attend: true,
    dob_required: true,
  )
end
########################################################################
# Actual Memberships

create_price_group!(launch_pricing)
