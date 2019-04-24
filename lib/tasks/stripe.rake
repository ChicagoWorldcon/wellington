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

namespace :stripe do
  namespace :sync do
    desc "Updates users with stripe Customer IDs"
    task customers: "assert:setup" do
      puts "Starting run, #{User.in_stripe.count}/#{User.count} users synced with stripe"
      Stripe::SyncCustomers.new.call
      puts "Ended run, #{User.in_stripe.count}/#{User.count} users synced with stripe"
    end

    desc "Updates stripe descriptions to match local"
    task charges: "assert:setup" do
      # So initially stripe charges had the description "CoNZealand Payment" which is ugly. Lets fix that.
      Charge.stripe.joins(:user).find_each do |charge|
        stripe_charge = Stripe::Charge.retrieve(charge.stripe_id)
        accounts_charge_description = ChargeDescription.new(charge).for_accounts

        next if stripe_charge.description == accounts_charge_description

        Stripe::Charge.update(charge.stripe_id,
          customer: user.stripe_id,
          description: accounts_charge_description,
          receipt_email: user.email,
        )
      end

      Charge.find_each do |charge|
        charge.update!(comment: charge_describer.for_users)
      end
    end
  end

  namespace :assert do
    task setup: :environment do
      if !ENV["STRIPE_PRIVATE_KEY"].present? || !ENV["STRIPE_PUBLIC_KEY"].present?
        raise "Bailing, please set STRIPE_PRIVATE_KEY and STRIPE_PUBLIC_KEY"
      end
    end
  end
end
