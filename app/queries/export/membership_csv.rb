# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
# Copyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# 1-Feb-21 FNB Change hard-coding from Chicago to DC

require "csv"

class Export::MembershipCsv
  def call
    return if DcContact.none?

    buff = StringIO.new
    csv = CSV.new(buff)

    csv << Export::MembershipRow::HEADINGS
    contacts = DcContact.joins(Export::MembershipRow::JOINS).eager_load(Export::MembershipRow::JOINS)
    contacts.merge(Claim.active).find_each do |contact|
      csv << Export::MembershipRow.new(contact).values
    end

    buff.string
  end
end
