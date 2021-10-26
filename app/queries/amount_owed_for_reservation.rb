# frozen_string_literal: true

# Copyright 2019 AJ Esler
# Copyright 2019 Matthew B. Gray
# Copyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");
# 26-Oct-21 FNB Updated to exclude site selection payments from calculation

# AmountOwedForReservation compares successful Charge records on the Reservation to the cost of a Membership
class AmountOwedForReservation
  attr_reader :reservation

  def initialize(reservation)
    @reservation = reservation
  end

  def amount_owed
    paid_so_far = Money.new(reservation.charges.where(site: nil, state: :successful).pluck('SUM(amount_cents)').sum)
    reservation.membership.price - paid_so_far
  end
end
