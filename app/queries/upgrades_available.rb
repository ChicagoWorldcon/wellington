# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
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

# UpgradesAvailable query defines what upgrades you can get to from your current membership
# Upgrades are always available when they're of higher value
class UpgradesAvailable
  attr_reader :membership

  def initialize(from:)
    @membership = Membership.find_by(name: from)
  end

  def call
    upgrades = {}
    Membership.active.where("price > ?", membership.price).find_each do |option|
      upgrades[option.name] = option.price - membership.price
    end
    upgrades.with_indifferent_access.freeze
  end
end
