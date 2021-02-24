# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
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

# ChargeDescription gives a description based on the state of the charge taking into account the time of the charge
# The goal is that you may build desciptions based on the history of charges against a reservation
# And to create a Charge#description with a hat tip to previous charge records
# And so that accountants get really nice text in reports
class ChargeDescription
  include ActionView::Helpers::NumberHelper

  attr_reader :charge

  def initialize(charge)
    @charge = charge
  end

  def for_users
    [
      maybe_charge_state,
      formatted_amount,
      upgrade_maybe,
      instalment_or_paid,
      "with",
      payment_type,
      "for",
      membership_type,
    ].compact.join(" ")
  end

  def for_accounts
    [
      formatted_amount,
      upgrade_maybe,
      instalment_or_paid,
      "for",
      maybe_member_name,
      "as",
      membership_type,
    ].compact.join(" ")
  end

  private

  def maybe_charge_state
    if !charge.successful?
      charge.state.humanize
    end
  end

  def payment_type
    if charge.stripe?
      "Credit Card"
    else
      charge.transfer.humanize
    end
  end

  def instalment_or_paid
    if !charge.successful?
      "Payment"
    elsif charges_so_far.sum(&:amount) + charge.amount < charged_membership.price
      "Instalment"
    else
      "Fully Paid"
    end
  end

  def maybe_member_name
    #TODO: Make sure a version of this for cart is present
    claims = charge.buyable.claims
    active_claim = claims.active_at(charge_active_at).first
    active_claim.contact
  end

  def membership_type
    #TODO: Make sure a version of this for cart is present
    "#{charged_membership} member #{charge.buyable.membership_number}"
  end

  def charged_membership
    #TODO: Make sure a version of this for cart is present
    return @charged_membership if @charged_membership.present?

    orders = charge.buyable.orders
    @charged_membership = orders.active_at(charge_active_at).first.membership
  end

  def upgrade_maybe
    if orders_so_far.count > 1
      "Upgrade"
    else
      nil
    end
  end

  def orders_so_far
    charge.buyable.orders.where("created_at <= ?", charge_active_at)
  end

  def charges_so_far
    successful = charge.buyable.charges.successful
    successful.where.not(id: charge.id).where("created_at < ?", charge_active_at)
  end

  def formatted_amount
    charge.amount.format(with_currency: true)
  end

  # This makes it pretty clear we'll be within the thresholds, avoids floating point errors
  # that may rise from how Postgres stores dates
  def charge_active_at
    @charge_active_from ||= charge.created_at + 1.second
  end
end
