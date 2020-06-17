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

class UserMailerPreview < ActionMailer::Preview
  StubReservation = Struct.new(:name, :number, :instalment?, :paid?)
  StubUser = Struct.new(:email, :login_url)
  StubCharge = Struct.new(:id, :amount)

  def paid
    PaymentMailer.paid(
      user: Charge.last.user,
      charge: Charge.last,
    )
  end

  def instalment
    PaymentMailer.instalment(
      user: Charge.last.user,
      charge: Charge.last,
      outstanding_amount: 42_00,
    )
  end
end
