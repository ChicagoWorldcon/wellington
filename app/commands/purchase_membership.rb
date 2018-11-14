# frozen_string_literal: true

# Copyright 2018 Matthew B. Gray
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

#       User ---------,
#      /   \           \
#     /     \           ^
#    ^       ^        Offer
# Charge    Claim     v   v
#    v       v       /     \
#     \     /       /       \
#      \   /    Product  Membership
#     Purchase      \       /
#         \          \     /
#          \          ^   ^
#           `--------< Order
#
# PurchaseMembership takes a user and a membership and creates a claim and purchase for them.
class PurchaseMembership
  attr_reader :customer, :membership

  def initialize(membership, customer:)
    @customer = customer
    @membership = membership
  end

  def call
    customer.transaction do
      as_at = Time.now
      purchase = Purchase.installment.create!
      order = Order.create!(active_from: as_at, membership: membership, purchase: purchase)
      claim = Claim.create!(active_from: as_at, user: customer, purchase: purchase)
      purchase
    end
  end
end
