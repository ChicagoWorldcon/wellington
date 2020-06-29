# frozen_string_literal: true
#
# Copyright 2019 Matthew B. Gray
# Copyright 2019 Chris Rose
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
  can_attend: false,

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
  can_attend: true,
)
