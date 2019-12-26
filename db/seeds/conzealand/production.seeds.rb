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

presupport_open = "2004-09-06".to_time
con_announced = "2018-08-25".to_time
price_change_1 = "2019-06-16 23:59:59 NZDT".to_time

########################################
# Presupport membership types

Membership.create!(
  "name": "silver_fern",
  "active_from": presupport_open,
  "active_to": con_announced,
  "description": "Presupport membership",
  "can_vote": false,
  "can_nominate": false,
  "can_site_select": false,
  "can_attend": false,
  "price": Money.new(32000),
)
Membership.create!(
  "name": "kiwi",
  "active_from": presupport_open,
  "active_to": con_announced,
  "description": "Presupport membership",
  "can_vote": false,
  "can_nominate": false,
  "can_site_select": false,
  "can_attend": false,
  "price": Money.new(5000),
)
Membership.create!(
  "name": "tuatara",
  "active_from": presupport_open,
  "active_to": con_announced,
  "description": "Presupport membership",
  "can_vote": false,
  "can_nominate": false,
  "can_site_select": false,
  "can_attend": false,
  "price": Money.new(0),
)
Membership.create!(
  "name": "pre_oppose",
  "active_from": presupport_open,
  "active_to": con_announced,
  "description": "Presupport membership",
  "can_vote": false,
  "can_nominate": false,
  "can_site_select": false,
  "can_attend": false,
  "price": Money.new(0),
)
Membership.create!(
  "name": "pre_support",
  "active_from": presupport_open,
  "active_to": con_announced,
  "description": "Presupport membership",
  "can_vote": false,
  "can_nominate": false,
  "can_site_select": false,
  "can_attend": false,
  "price": Money.new(0),
)

########################################
# Con membership types

Membership.create!(
  "name": "adult",
  "active_from": con_announced,
  "active_to": price_change_1,
  "description": nil,
  "can_vote": true,
  "can_nominate": true,
  "can_site_select": true,
  "can_attend": true,
  "price": Money.new(37000),
)
Membership.create!(
  "name": "adult",
  "active_from": price_change_1,
  "active_to": nil,
  "description": nil,
  "can_vote": true,
  "can_nominate": true,
  "can_site_select": true,
  "can_attend": true,
  "price": Money.new(40000),
)

Membership.create!(
  "name": "young_adult",
  "active_from": con_announced,
  "active_to": price_change_1,
  "description": "born in or after 2000",
  "can_vote": true,
  "can_nominate": true,
  "can_site_select": true,
  "can_attend": true,
  "price": Money.new(22500),
)
Membership.create!(
  "name": "young_adult",
  "active_from": price_change_1,
  "active_to": nil,
  "description": "born in or after 2000",
  "can_vote": true,
  "can_nominate": true,
  "can_site_select": true,
  "can_attend": true,
  "price": Money.new(25000),
)

Membership.create!(
  "name": "supporting+",
  "active_from": con_announced,
  "active_to": price_change_1,
  "description": nil,
  "can_vote": true,
  "can_nominate": true,
  "can_site_select": true,
  "can_attend": false,
  "price": Money.new(12500),
)
Membership.create!(
  "name": "unwaged",
  "active_from": con_announced,
  "active_to": nil, # no planned price rise
  "can_vote": true,
  "can_nominate": true,
  "can_site_select": true,
  "can_attend": true,
  "price": Money.new(22500),
)
Membership.create!(
  "name": "child",
  "active_from": con_announced,
  "active_to": nil, # no planned price rise
  "description": "born in or after 2005",
  "can_vote": false,
  "can_nominate": false,
  "can_site_select": false,
  "can_attend": true,
  "price": Money.new(10500),
)
Membership.create!(
  "name": "kid_in_tow",
  "active_from": con_announced,
  "active_to": nil, # no planned price rise
  "description": "born in or after 2015",
  "can_vote": false,
  "can_nominate": false,
  "can_site_select": false,
  "can_attend": true,
  "price": Money.new(0),
)
Membership.create!(
  "name": "supporting",
  "active_from": con_announced,
  "active_to": nil, # no planned price rise
  "description": nil,
  "can_vote": true,
  "can_nominate": true,
  "can_site_select": true,
  "can_attend": false,
  "price": Money.new(7500),
)

########################################
# Other prod seeds

require_relative "production_hugo.seeds.rb"
require_relative "production_dublin.seeds.rb"
