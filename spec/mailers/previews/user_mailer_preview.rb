# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
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

class PaymentMailerPreview < ActionMailer::Preview
  StubPurchase = Struct.new(:name, :number, :installment?, :paid?)
  StubUser = Struct.new(:email, :login_url)
  StubCharge = Struct.new(:id, :amount)

  def new_member
    # TODO Use models that represent this mailer
    purchase = StubPurchase.new("Adult", 42, true, false)
    user = StubUser.new("first.user@example.org", "https://members-staging.conzealand.nz/login/test@conzealand.nz/pahJie3v")
    charge = StubCharge.new("stub-charge-1234", 300_00)
    outstanding_amount = 70_00

    PaymentMailer.new_member(user: user, purchase: purchase, charge: charge, outstanding_amount: outstanding_amount)
  end

  def installment_payment
    purchase = StubPurchase.new("Adult", 42, true, false)
    user = StubUser.new("first.user@example.org", "https://members-staging.conzealand.nz/login/test@conzealand.nz/pahJie3v")
    charge = StubCharge.new("stub-charge-1234", 150_00)
    outstanding_amount = 70_00

    PaymentMailer.installment_payment(user: user, purchase: purchase, charge: charge, outstanding_amount: outstanding_amount)
  end
end
