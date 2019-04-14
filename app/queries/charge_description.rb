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

# ChargeDescription gives a description based on the state of the charge taking into account the time of the charge.
# The goal is that you may retrospectively create these descriptions.
class ChargeDescription
  include ActionView::Helpers::NumberHelper

  attr_reader :charge

  def initialize(charge)
    @charge = charge
  end

  def for_users
    [
      formatted_amount,
      upgrade_maybe,
      installment_or_paid,
      "for",
      membership,
    ].compact.join(" ")
  end

  private

  def installment_or_paid
    if charges_so_far.sum(:amount) < charged_membership.price
      "Installment"
    else
      "Paid"
    end
  end

  def membership
    "#{charged_membership} member #{charge.purchase.membership_number}"
  end

  def charged_membership
    return @charged_membership if @charged_membership.present?

    orders = charge.purchase.orders
    @charged_membership = orders.active_at(charge.created_at).first.membership
  end

  def upgrade_maybe
    if orders_so_far.count > 1
      "Upgrade"
    else
      nil
    end
  end

  def orders_so_far
    charge.purchase.orders.where("created_at <= ?", charge.created_at)
  end

  def charges_so_far
    charge.purchase.charges.successful.where("created_at <= ?", charge.created_at)
  end

  def formatted_amount
    "#{number_to_currency(charge.amount / 100)} NZD"
  end
end
