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

# UpgradeMembership command upgrades membership between two levels
# Truthy return means upgrade was successful, otherwise check errors for explanation
class UpgradeMembership
  attr_reader :membership, :target_level

  def initialize(membership, target_level)
    @membership = membership
    @target_level = target_level
  end

  def call
    check_availability
    return false if errors.any?

    membership.update!(level: target_level)
  end

  def errors
    @errors ||= []
  end

  private

  # TODO get nicer user facing text for these membreship levels
  def check_availability
    prices = UpgradesAvailable.new(from: membership.level).call
    if !prices.has_key?(target_level)
      errors << "#{membership.level} cannot upgrade to #{target_level}"
    end
  end
end
