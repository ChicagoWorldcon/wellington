# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2019 AJ Esler
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

# PaymentAmountOptions is used to restrict the instalment amounts available to a User when paying for a Reservation
# It's configurable in your env via INSTALMENT_MIN_PAYMENT_CENTS and INSTALMENT_PAYMENT_STEP_CENTS
class PaymentAmountOptions
  MIN_PAYMENT = Money.new(ENV["INSTALMENT_MIN_PAYMENT_CENTS"] || 75_00)
  PAYMENT_STEP = Money.new(ENV["INSTALMENT_PAYMENT_STEP_CENTS"] || 50_00)
  INSTALMENT_ENABLED = !(ENV["INSTALMENT_ENABLED"].to_s.downcase == "false")

  attr_reader :amount_owed

  def initialize(amount_owed)
    @amount_owed = amount_owed
  end

  def amounts
    return [] if minimum_payment <= 0
    return [amount_owed] unless INSTALMENT_ENABLED

    instalments.append(amount_owed)
  end

  private

  def instalments
    instalments = []
    amount = minimum_payment
    while amount < amount_owed
      instalments << amount
      amount += PAYMENT_STEP
    end
    instalments
  end

  def minimum_payment
    return amount_owed unless INSTALMENT_ENABLED

    amount_owed < MIN_PAYMENT ? amount_owed : MIN_PAYMENT
  end
end
