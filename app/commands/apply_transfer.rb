# frozen_string_literal: true

# Copyright 2020 Matthew B. Gray
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

# ApplyTransfer command makes old claims to reservation inactive and sets up new claim for receiver
# Truthy return means transfer was successful, otherwise check errors for explanation
class ApplyTransfer
  attr_reader :reservation, :sender, :receiver, :errors, :audit_by

  def initialize(reservation, from:, to:, audit_by:, copy_contact: false)
    @reservation = reservation
    @sender = from
    @receiver = to
    @audit_by = audit_by
    @copy_contact = copy_contact
  end

  def call
    @errors = []
    reservation.transaction do
      check_reservation
      return false if errors.any?

      note_content = "#{audit_by} tansferred ##{reservation.membership_number} from #{sender.email} to #{receiver.email}"
      sender.notes.create!(content: note_content)
      receiver.notes.create!(content: note_content)

      as_at = Time.now
      old_claim.update!(active_to: as_at)
      new_claim = receiver.claims.create!(active_from: as_at, reservation: reservation)

      if copy_contact?
        coppied_contact = old_claim.contact.dup
        coppied_contact.update!(claim: new_claim)
      end

      new_claim
    end
  end

  def error_message
    errors.to_sentence
  end

  def copy_contact?
    @copy_contact.present?
  end

  private

  def check_reservation
    if !old_claim.present?
      errors << "reservation not held"
      return # bail, avoid leaking information about reservations
    end

    if !old_claim.transferable?
      errors << "claim is not transferable"
    end

    if !reservation.transferable?
      errors << "reservation is not transferable"
    end
  end

  def old_claim
    @old_claim ||= sender.claims.active.find_by(reservation: reservation)
  end
end
