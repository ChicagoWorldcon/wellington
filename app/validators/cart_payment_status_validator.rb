# frozen_string_literal: true
#
# Copyright 2021 Victoria Garcia
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

class CartPaymentStatusValidator < ActiveModel::Validator
  def validate(record)

    case record.status
    when Cart::FOR_NOW

      # some stuff happens
      record.errors.add(:status, :sucky_status, message: "")

    when Cart::FOR_LATER

      # some stuff happens
      record.errors.add(:status, :sucky_status, message: "")
    when Cart::AWAITING_CHEQUE

      # some stuff happens
      record.errors.add(:status, :sucky_status, message: "")
    when Cart::PAID

      # some stuff happens
      record.errors.add(:status, :sucky_status, message: "")
    else

      # some stuff happens
      record.errors.add(:status, :unrecognized_status, message: "#{record.status} is not a recognized status for a #{record.class}")
    end


  end
end
