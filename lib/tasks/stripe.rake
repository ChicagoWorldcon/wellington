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


    # TODO: Hard to tell if this was a one-time task for CoNZealand or a recurring maintenance bit.
    # If the latter, this may need to be updated to be inclusive of charges made using the Stripe Checkout flow.
    # For those, we store the *checkout session id* rather than the charge id.
    # Checkout session ids are prefixed with `cs_` and so this code should silently ignore those.
    desc "Updates stripe descriptions to match local"
    task charges: "assert:setup" do
      raise "I may have broken as part of a Stripe API migration! Please check comments in stripe.rake for more details."

      # So initially stripe charges had the description "CoNZealand Payment" which is ugly. Lets fix that.
      Charge.stripe.joins(:user).find_each do |charge|
        next unless charge.stripe_id.starts_with?("ch_")

        stripe_charge = Stripe::Charge.retrieve(charge.stripe_id)
        accounts_charge_description = ChargeDescription.new(charge).for_accounts
        next if stripe_charge.description == accounts_charge_description

        Stripe::Charge.update(charge.stripe_id, description: accounts_charge_description)
      end

      Charge.find_each do |charge|
        charge.update!(comment: ChargeDescription.new(charge).for_users)
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
