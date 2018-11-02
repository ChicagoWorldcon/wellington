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
  attr_reader :purchase, :to_membership

  def initialize(purchase, to:)
    @purchase = purchase
    @to_membership = to
  end

  def call
    check_availability
    return false if errors.any?

    purchase.transaction do
      as_at = Time.now
      old_order.update!(active_to: as_at)
      purchase.orders.create!(active_from: as_at)
    end
  end

  def errors
    @errors ||= []
  end

  private

  # TODO get nicer user facing text for these membership levels
  def check_availability
    prices = UpgradesAvailable.new(from: purchase.membership.name).call
    if !prices.has_key?(to_membership.name)
      errors << "#{purchase.membership.name} cannot upgrade to #{to_membership.name}"
    end
  end

  def old_order
    purchase.active_order
  end
end
