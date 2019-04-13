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
  desc "Updates users with stripe Customer IDs"
  task sync_customers: :environment do
    lookup = {}
    exceptions = []

    Stripe::Customer.list.auto_paging_each do |customer|
      if customer.email.nil?
        exceptions << customer
      else
        lookup[customer.email.downcase] ||= customer
      end
    end

    User.where(email: lookup.keys).find_each(batch_size: 10) do |user|
      stripe_id = lookup[user.email]&.id
      user.update!(stripe_id: stripe_id) if stripe_id.present?
    end
  end
end
