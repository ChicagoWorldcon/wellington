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

# ShoppingCart is a class that represents a link to Stripe, tracking line items that are ready for checkout
class ShoppingCart
  def self.for(user)
    if user.stripe_customer_id.nil?
      stripe_customer = Stripe::Customer.create(email: user.email)
      user.update!(stripe_customer_id: stripe_customer.id)
    end

    ShoppingCart.new
  end
end
