# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
# Copyright 2021 Fred Bauer
#
# Licensed under the Apache License, Version 2.0 (the "License");
#
#24-May-21 FNB 
module ReservationsHelper
  def card_classes(reservation)
    if !reservation.paid?
      "dark-card text-white border-light" # was "text-white bg-dark border-light"
    else
      "light-card" #bg-neutral
    end
  end

  def form_input_errors(model, field)
    model_errors = model.errors.messages[field]
    model_errors.present? && model_errors.to_sentence.humanize.concat(".")
  end

  def update_transfer_path(transfer)
    reservation_transfer_path(
      reservation_id: transfer.reservation_id,
      id: transfer.new_owner,
    )
  end

  def amount_to_pay(reservation)
    amount = AmountOwedForReservation.new(reservation).amount_owed
    amount.format(with_currency: true)
  end

  def index_links(reservation)
    links = show_links(reservation)
    links << link_to("Review or update details", reservation_path(reservation))
  end

  def show_links(reservation)
    [].tap do |links|
      if reservation.instalment?
        links << link_to("Make a payment", new_reservation_charge_path(reservation))
      elsif UpgradeOffer.from(reservation.membership).any?
        links << link_to("Upgrade membership", reservation_upgrades_path(reservation))
      end
    end
  end
end
