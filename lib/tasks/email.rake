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

namespace :email do
  desc "Contacts members who may have purchased more than one membership by mistake"
  task duplicate_memberships: :environment do
    member_lookup = {}

    Purchase.joins(active_claim: [:user, :detail]).find_each(batch_size: 10) do |purchase|
      name = purchase.active_claim.detail.to_s
      next unless name.match(/ /) # skip people who don't have a full name listed
      member_lookup[name] ||= []
      member_lookup[name] << purchase
    end

    duplicates = member_lookup.select { |_, purchases| purchases.count > 1 }

    puts "#{duplicates.count} duplicates found"

    duplicates.each do |name, purchases|
      users = User.joins(:purchases).where(purchases: {id: purchases.map(&:id)})
      emails = users.pluck(:email)
      numbers = purchases.map(&:membership_number)
      puts "member #{numbers.join(",")} => #{emails.to_sentence}"

      emails.each do |email|
        MembershipMailer.duplicate_purchases(email: email, purchases: purchases).deliver_now
      end
    end
  end
end
