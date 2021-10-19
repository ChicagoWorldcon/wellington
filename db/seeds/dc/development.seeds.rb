# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
# Copyright 2020 Fred Bauer
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
con_announced = "2019-08-25".to_time
price_change_1 = "2021-11-2 00:00:01 EDT".to_time

#clean up
Membership.delete_all

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
  "price": Money.new(15500),
)

Membership.create!(
  "name": "young_adult",
  "active_from": con_announced,
  "active_to": price_change_1,
  "description": "born after August 23rd, 1996",
  "can_vote": true,
  "can_nominate": true,
  "can_site_select": true,
  "can_attend": true,
  "price": Money.new(8000),
)

Membership.create!(
  "name": "supporting",
  "active_from": con_announced,
  "active_to": price_change_1,
  "description": nil,
  "can_vote": true,
  "can_nominate": true,
  "can_site_select": true,
  "can_attend": false,
  "price": Money.new(4500),
)

Membership.create!(
  "name": "child",
  "active_from": con_announced,
  "active_to": price_change_1,
  "description": "born after August 23rd, 2009",
  "can_vote": false,
  "can_nominate": false,
  "can_site_select": false,
  "can_attend": true,
  "price": Money.new(6500),
)

Membership.create!(
  "name": "kid_in_tow",
  "active_from": con_announced,
  "active_to": nil,
  "description": "born after August 23rd, 1996",
  "can_vote": false,
  "can_nominate": false,
  "can_site_select": false,
  "can_attend": false,
  "price": Money.new(000),
)


########################################
# Other prod data migrations that happened post deploy

#require_relative "production_hugo.seeds.rb"
#require_relative "production_dublin.seeds.rb"
#require_relative "production_hugo_ordering.seeds.rb"
