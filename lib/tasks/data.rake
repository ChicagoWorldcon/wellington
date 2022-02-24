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
#
# Adapted from
# https://www.ombulabs.com/blog/rails/data-migrations/three-useful-data-migrations-patterns-in-rails.html

namespace :data_migration do

  desc "Assigns a price_lock_date to Reservation instances where both (a) that field is currently set to nil, and (b) The associated Contact instance has its installment_wanted field set to 'true'"

  task :backdate_reservation_price_lock_dates => :environment do
    puts "\n Preparing to update any reservations that qualify for backdated price lock dates. \n"
    PriceLockBackdater.new.call
    puts "\n Price lock date backdating process completed.\n"
  end
end
