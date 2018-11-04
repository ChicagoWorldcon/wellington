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

# UpgradeOffer holds information about a membership upgrade at a price
class UpgradeOffer
  attr_reader :from_membership, :to_membership

  def initialize(from:, to:)
    @from_membership = from
    @to_membership = to
  end

  def title
    "Upgrade #{from_membership.name} to #{to_membership.name}"
  end

  def price
    @price ||= to_membership.price - from_membership.price
  end
end
