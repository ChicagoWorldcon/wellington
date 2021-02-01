# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
# Copyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License")
# 1-Feb-21 Change hard-coding from Chicago to DC

class Export::MembershipRow
  # JOINS describe fields needed to be preloaded on Detail for speed
  # These are tied to the Detail model
  JOINS = {
    claim: [
      :user,
      { reservation: :membership },
    ]
  }.freeze

  CONTACT_KEYS = DcContact.new.attributes.keys.freeze

  HEADINGS = [
    "membership_number",
    "email",
    "membership_name",
    "name_to_list",
    *CONTACT_KEYS,
  ].freeze

  attr_reader :contact

  def initialize(contact)
    @contact = contact
  end

  def values
    reservation = contact.claim.reservation
    contact_values = contact.slice(CONTACT_KEYS).values.map(&:to_s)

    [
      reservation.membership_number,
      contact.claim.user.email,
      reservation.membership.name,
      contact.to_s,
      *contact_values,
    ]
  end
end
