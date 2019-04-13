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

class Stripe::SyncCustomers
  def call
    Stripe::Customer.list.auto_paging_each do |stripe_customer|
      next if stripe_customer.id.nil?
      next if stripe_customer.email.nil?

      user = User.find_or_create_by(email: stripe_customer.email.downcase)

      if user.stripe_id && user.stripe_id != stripe_customer.id
        Rails.logger.warn "#{user.email} has doppleganger in stripe, preferring #{user.stripe_id} for members area"
      end

      next if user.stripe_id.present?
      user.update!(stripe_id: stripe_customer.id)
    end
  end
end
