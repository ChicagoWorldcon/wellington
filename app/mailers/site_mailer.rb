# frozen_string_literal: true

# Copyright 2019 AJ Esler
# Copyright 2019 Steven C Hartley
# Copyright 2020 Matthew B. Gray
# Copyright 2020 Victoria Garcia
# Copyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# 24-Oct-21 FNB cloned from payment_mailer

# Preview all emails at http://localhost:3000/rails/mailers/payment_mailer
class SiteMailer < ApplicationMailer
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
      subject: "#{worldcon_public_name} Payment: Site Selection Payment for member # #{@reservation.membership_number}"
    )
  end

end
