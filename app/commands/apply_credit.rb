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

# CreditAccount takes a reservation and credits an amount towards it
class ApplyCredit
  attr_reader :reservation, :amount

  def initialize(reservation, amount)
    @reservation = reservation
    @amount = amount
  end

  def call
    account_credit = reservation.charges.successful.cash.create!(
      user: reservation.user,
      amount: amount,
      comment: "account credit",
    )
    account_credit.update!(comment: ChargeDescription.new(account_credit).for_users)

    if fully_paid?
      reservation.update!(state: Reservation::PAID)
    end

    true
  end

  private

  def fully_paid?
    successful_payments >= reservation.membership.price
  end

  def successful_payments
    reservation.charges.successful.sum(&:amount)
  end
end
