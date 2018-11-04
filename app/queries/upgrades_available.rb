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

# UpgradesAvailable query defines what upgrades you can get to from your current membership Upgrades are always
# available when they're of higher value. You can narrow your search by specifying a target membership with the to
# keyword on initialize.
class UpgradesAvailable
  attr_reader :current_membership, :target_membership

  def initialize(from:, to: nil)
    @current_membership = Membership.find_by(name: from)
    @target_membership = to
  end

  def call
    options = Membership.active.where("price > ?", current_membership.price)
    options = options.where(id: target_membership) if target_membership.present?
    options.map do |membership|
      UpgradeOffer.new(from: current_membership, to: membership)
    end
  end
end
