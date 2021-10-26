# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
# Copyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# 26-Oct-21 FNB updated charge text to account for site selection payment

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
    claims = charge.reservation.claims
    active_claim = claims.active_at(charge_active_at).first
    active_claim.contact
  end

  def membership_type
    return "Site Selection for member #{charge.reservation.membership_number} " if charge.site
    "#{charged_membership} member #{charge.reservation.membership_number}"
  end

  def charged_membership
    return @charged_membership if @charged_membership.present?

    orders = charge.reservation.orders
    @charged_membership = orders.active_at(charge_active_at).first.membership
  end

  def upgrade_maybe
    return if charge.site
    if orders_so_far.count > 1
      "Upgrade"
    else
      nil
    end
  end

  def orders_so_far
    charge.reservation.orders.where("created_at <= ?", charge_active_at)
  end

  def charges_so_far
    successful = charge.reservation.charges.successful
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
