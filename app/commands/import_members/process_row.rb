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

class ImportMembers::ProcessRow
  attr_reader :row_data, :comment

  def initialize(row_data, comment)
    @row_data = row_data
    @comment = comment
  end

  def call
    new_user = User.create!(email: row_data[13])
    membership = Membership.find_by(name: row_data[14])
    command = PurchaseMembership.new(membership, customer: new_user)

    if new_purchase = command.call
      new_purchase.update!(state: Purchase::PAID)
      Charge.cash.successful.create!(
        user: new_user,
        purchase: new_purchase,
        amount: membership.price,
        comment: comment,
      )
    else
      errors << command.error_message
    end

    errors.none?
  end

  def errors
    @errors ||= []
  end

  def error_message
    errors.to_sentence
  end
end
