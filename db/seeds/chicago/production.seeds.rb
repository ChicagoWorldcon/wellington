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

Membership.create!(
  name: "Donor",
  price: Money.new(20_00),
  description: "With our thanks!",
)

Membership.create!(
  name: "Friend",
  price: Money.new(150_00),
  description: "Will convert to an attending membership automatically if you vote in tion in 2020",
)

Membership.create!(
  name: "Star",
  price: Money.new(500_00),
  description: "Will convert to an attending membership automatically if you vote in Site Selection in 2020, and hing cool for you at the convention! (Shhh…it’s a surprise!)",
)

# As of today, July 1, 2020, prices listed for the memberships below are
# straight-up fictional, and the years and descriptions are ganked, with updated cutoff years, from ConZealand. -VEG

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

########################################
# Other prod data migrations that happened post deploy

require_relative "development_hugo.seeds.rb"
require_relative "development_dublin.seeds.rb"
require_relative "development_hugo_ordering.seeds.rb"
