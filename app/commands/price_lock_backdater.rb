# frozen_string_literal: true

# Copyright 2022 Victoria Garcia*
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

# This command is run by a rake task during the migration progress.
# It finds reservations associated with chicago_contacts who requested installment
# plans.  The pricing structure for upgrades to such a membership is then locked
# to the date of the request for installment.

class PriceLockBackdater
  def errors
    @errors ||= []
  end

  def call
    puts "Searching for reservations that qualify for backdated price lock dates. \n"

    qualifying_reservations = NonPricelockedReservationsWithInstallmentRequests.new.call
    report_string = nil

    if qualifying_reservations.any?

      puts "Attempting to add backdated price lock dates to #{qualifying_reservations.size} reservations:\n\n"

      qualifying_reservations.each_with_index do |qual, i|
        our_reservation = Reservation.find_by(id: qual.id)
        new_error = nil
        new_error =  "Unable to find reservation: #{qual.id}." unless our_reservation

        if !new_error
          new_error =  "Unable to update reservation with id: #{qual.id}." unless our_reservation.update(price_lock_date:  qual.new_price_lock_date)
          our_reservation.reload if !new_error
        end

        puts "Updated reservation #{i}.".indent(5) unless new_error
        errors << new_error if new_error
      end

      not_updated = errors.size
      updated = qualifying_reservations.size - not_updated

      report_string = "\n Successfully updated #{updated} reservations."
      unless not_updated == 0
        report_string = report_string + "  Unable to update #{not_updated} qualifying reservation(s). Problem(s) as follows:\n#{errors.join(" \n")}"
      end
    else
      report_string = "\n No reservations that qualifed for backdated price lock dates were found!\n"
    end

    puts report_string
    return errors.empty?
  end
end
