# frozen_string_literal: true

# Copyright 2019 AJ Esler
# Copyright 2019 Steven C Hartley
# Copyright 2020 Matthew B. Gray
# Copyright 2020 Victoria Garcia
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
  include ApplicationHelper
  default from: $member_services_email

  def paid_one(user:, charge:)
    @worldcon_basic_greeting = worldcon_basic_greeting
    @worldcon_public_name = worldcon_public_name
    @worldcon_url_homepage = worldcon_url_homepage
    @charge = charge
    @reservation = charge.reservation
    @contact = @reservation.active_claim.contact

    mail(
      to: user.email,
      subject: "#{worldcon_public_name} Payment: Payment for member ##{@reservation.membership_number}"
    )
  end

  def paid(user:, charges:)
    @charges = charges
    @reservations = charge.map(&:reservation)
    @contacts = @reservations.map(&:active_claim).map(&:contact)

    mail(
      to: user.email,
      subject: "CoNZealand Payment: Payment for memberships"
    )
  end

  def instalment(user:, charge:, outstanding_amount:)
    @worldcon_basic_greeting = worldcon_basic_greeting
    @worldcon_public_name = worldcon_public_name
    @worldcon_url_homepage = worldcon_url_homepage
    @worldcon_public_name_spaceless = worldcon_public_name_spaceless

    @charge = charge
    @reservation = charge.reservation
    @contact = @reservation.active_claim.contact
    @outstanding_amount = outstanding_amount


    mail(
      to: user.email,
      subject: "#{worldcon_public_name} Payment: Instalment for member ##{@reservation.membership_number}"
    )
  end
end
