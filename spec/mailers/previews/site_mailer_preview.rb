# frozen_string_literal: true

# Copyright 2019 AJ Esler
# Copyright 2019 Matthew B. Gray
# Copyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# 24_oct-21 FNB cloned from payment mailer
class SiteMailerPreview < ActionMailer::Preview
  include ThemeConcern

  StubReservation = Struct.new(:name, :number, :active_claim, :instalment?, :paid?, :membership) do
    def membership_number
      number
    end
  end
  StubClaim = Struct.new(:contact)
  StubUser = Struct.new(:email, :login_url)
  StubCharge = Struct.new(:id, :amount)

  def paid
    SiteMailer.paid(
      user: Charge.last.user,
      charge: Charge.last,
    )
  end
end
