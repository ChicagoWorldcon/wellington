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

  def paid(user:, charge:)
    @worldcon_basic_greeting = worldcon_basic_greeting
    @worldcon_public_name = worldcon_public_name
    @worldcon_url_homepage = worldcon_url_homepage
    @worldcon_public_name_spaceless = worldcon_public_name_spaceless

    @charge = charge
    @reservation = charge.reservation
    @contact = @reservation.active_claim.contact

    mail(
      to: user.email,
      subject: "#{worldcon_public_name} Payment: Payment for member ##{@reservation.membership_number}"
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

  def waiting_for_cheque(user:, reservation:, outstanding_amount:)
    @worldcon_basic_greeting = worldcon_basic_greeting
    @worldcon_public_name = worldcon_public_name
    @worldcon_url_homepage = worldcon_url_homepage
    @worldcon_public_name_spaceless = worldcon_public_name_spaceless
    @worldcon_mailing_address = worldcon_registration_mailing_address

    @reservation = reservation
    @contact = @reservation.active_claim.contact
    @outstanding_amount = outstanding_amount

    # This is to the user email, instead of the contact, for two reasons:
    # 1. The contact may not have an email, not every con does
    # 2. The user is responsible for all payments, in our model, so they should get this.
    recipients = [user.email, $treasurer_email, $member_services_email]

    mail(
      from: $treasurer_email,
      to: recipients.join(","),
      subject: "#{worldcon_public_name} Payment instructions for member ##{@reservation.membership_number}"
    )
  end
end
