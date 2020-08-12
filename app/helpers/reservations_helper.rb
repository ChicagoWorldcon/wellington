# frozen_string_literal: true

# Copyright 2019 Matthew B. Gray
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

module ReservationsHelper
  def card_classes(reservation)
    if !reservation.paid?
      "text-white bg-dark border-light"
    end
  end

  def form_input_errors(model, field)
    model_errors = model.errors.messages[field]
    model_errors.present? && model_errors.to_sentence.humanize.concat(".")
  end

  def update_transfer_path(transfer)
    operator_reservation_transfer_path(
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
