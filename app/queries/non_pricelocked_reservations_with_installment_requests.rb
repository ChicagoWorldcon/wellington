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

class NonPricelockedReservationsWithInstallmentRequests

  def call
    Reservation.joins(claims: :chicago_contact).where(chicago_contacts: {installment_wanted: true}, reservations: {price_lock_date: nil}, claims: {active_from: ..Time.now, active_to: [nil, Time.now..]}).select('reservations.id as id, chicago_contacts.created_at as new_price_lock_date') 
  end
end
