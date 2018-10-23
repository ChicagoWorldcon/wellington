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
  LEVELS = {
    adult: {
      cost: 370_00
    },
    young_adult: {
      cost: 225_00
    },
    unwaged: {
      cost: 225_00
    },
    child: {
      cost: 105_00
    },
    kid_in_tow: {
      cost: 0
    },
    supporting: {
      cost: 75_00
    },
  }

  attr_reader :from

  def initialize(from:)
    @from = from
  end

  def call
    case from
    when :young_adult
      [:adult]
    else
      []
    end
  end
end
