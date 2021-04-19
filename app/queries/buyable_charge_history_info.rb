# frozen_string_literal: true

# Copyright 2019 AJ Esler
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

# BuyableChargeHistoryInfo is used in the Buyable
# module to get information related to charge
# history.   It is less specific/entangled than
# ReservationPaymentHistory, and eventually a lot of
# ReservationPaymentHistory probably ought to be
# moved into here.

class BuyableChargeHistoryInfo
  attr_reader :our_buyable

  def initialize(our_buyable)
    @our_buyable = our_buyable
  end

  def any_direct_charges_succeeded?
    Charge.successful.where(buyable: @our_buyable).exists?
  end

  def any_direct_charges?
    Charge.where(buyable: @our_buyable).exists?
  end

  def successful_direct_charge_tally
    Charge.successful.where(buyable: @our_buyable).inject(0) {|a, c| a + c.amount_cents}
  end
end
