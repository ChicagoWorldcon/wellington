# frozen_string_literal: true

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

class PaymentAmountOptions
  MIN_PAYMENT_AMOUNT = 75_00 # cents
  PAYMENT_STEP = 50_00 # cents

  attr_reader :amount_owed

  def initialize(amount_owed)
    @amount_owed = amount_owed
  end

  def amounts
    return [] if minimum_payment <= 0

    (minimum_payment...amount_owed).step(PAYMENT_STEP).to_a.append(amount_owed).uniq
  end

  private

  def minimum_payment
    amount_owed < MIN_PAYMENT_AMOUNT ? amount_owed : MIN_PAYMENT_AMOUNT
  end
end
