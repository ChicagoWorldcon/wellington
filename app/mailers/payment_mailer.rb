# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
# Copyright 2019 Steven C Hartley
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

# Preview all emails at http://localhost:3000/rails/mailers/payment_mailer
class PaymentMailer < ApplicationMailer
  default from: ENV["EMAIL_PAYMENTS"]

  def new_member(user:, purchase:, charge:, outstanding_amount:)
    @user = user
    @purchase = purchase
    @charge = charge
    @outstanding_amount = outstanding_amount

    mail(to: user.email) do |format|
      #text must be called before html.
      format.text
      format.html
    end
  end
end
