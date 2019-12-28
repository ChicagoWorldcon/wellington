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

dublin_import = "2019-12-01".to_time
Membership.create!(
  "name": "dublin_2019",
  "description": "Attended Dublin in 2019",
  "active_from": dublin_import,
  "active_to": dublin_import, # not available to the general public
  "can_vote": false,
  "can_nominate": true,
  "can_site_select": false,
  "can_attend": false, # can nominate, but can't vote
  "price": Money.new(0),
)
