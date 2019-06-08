# frozen_string_literal: true

# Copyright 2019 AJ Esler
# Copyright 2019 Matthew B. Gray
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

  def paid(user:, charge:)
    @charge = charge
    @reservation = charge.reservation
    @detail = @reservation.active_claim.detail

    mail(to: user.email, subject: "CoNZealand Payment: Payment for member ##{@reservation.membership_number}") do |format|
      # text must be called before html.
      format.text
      format.html
    end
  end

  def installment(user:, charge:, outstanding_amount:)
    @charge = charge
    @reservation = charge.reservation
    @detail = @reservation.active_claim.detail
    @outstanding_amount = outstanding_amount

    mail(to: user.email, subject: "CoNZealand Payment: Installment for member ##{@reservation.membership_number}") do |format|
      # text must be called before html.
      format.text
      format.html
    end
  end
end
