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

# ApplyCredit takes a reservation and credits a cash amount towards it
# Used by a Operator user who is taking money by cheque or cash at the table of a con
# If this does fail, it's going to 500 and roll back
class ApplyCredit
  attr_reader :reservation, :amount, :audit_by

  def initialize(reservation, amount, audit_by:)
    @reservation = reservation
    @amount = amount
    @audit_by = audit_by
  end

  def call
    create_successful_cash_charge
    create_audit_note

    if fully_paid?
      reservation.update!(state: Reservation::PAID)
    end

    true
  end

  private

  def fully_paid?
    AmountOwedForReservation.new(reservation).amount_owed <= 0
  end

  def create_successful_cash_charge
    account_credit = reservation.charges.successful.cash.create!(
      user: reservation.user,
      amount: amount,
      comment: "account credit",
    )
    account_credit.update!(comment: ChargeDescription.new(account_credit).for_users)
  end

  def create_audit_note
    reservation.user.notes.create!(
      content: %{
        #{audit_by} set credit
        for #{amount.format}
        to ##{reservation.membership_number}
      }
    )
  end
end
