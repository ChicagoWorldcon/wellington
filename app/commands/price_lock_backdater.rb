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

class PriceLockBackdater
  def self.call
    puts "Searching for reservations that qualify for backdated price lock dates. \n"

    qualifying_reservations = NonPricelockedReservationsWithInstallmentRequests.call

    if qualifying_reservations.any?

      puts "Giving backdated price lock dates to #{qualifying_reservations.count} reservations:\n\n"

      ActiveRecord::Base.transaction do
        qualifying_reservations.each_with_index do |qual, i|
          qual.update!(price_lock_date:  qual.created_at)
          puts "Updated reservation \# #{i}.".indent(3)
        end
      end

      puts "\n All reservations qualifying for a backdated price lock date have been updated! \n\n"

    else

      puts "\n No reservations that qualifed for backdated price lock dates were found!\n\n"
      
    end
  end
end
