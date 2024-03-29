
# frozen_string_literal: true
#
# Copyright 2020, 2021 Victoria Garcia
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

# A Cart is a collection of CartItems.  A user can have two active carts at a
# time: One base Cart, and one with saved items (with status: for_later.)
# (The two active carts form a CartPair, which is a PORO that has a model but
# no presence of its own in the database.)

class Cart < ApplicationRecord
  require 'money'
  include Buyable
  include ActiveScopes

  FOR_LATER = "for_later"
  FOR_NOW = "for_now"
  AWAITING_CHEQUE = "awaiting_cheque"
  PAID = "paid"

  STATUS_OPTIONS = [
    FOR_LATER,
    FOR_NOW,
    AWAITING_CHEQUE,
    PAID
  ].freeze

  belongs_to :user, required: true
  has_many :charges, :as => :buyable

  has_many :cart_items

  validates :status, presence: true, :inclusion => { in: STATUS_OPTIONS }
  #validates_with CartPaymentStatusValidator

  # A user has one active cart at a time
  # TODO:  WRITE A CUSTOM VALIDATOR SO THAT A USER CAN HAVE:
  # One active, pending cart; one active, processing cart; infinite paid and/or inactive carts
  # --OR AFTER REVISION--
  # One active, for_now cart, one active, for_later cart, and infinite
  # paid or awaiting_cheque carts
  # validates :user, uniqueness: { conditions: -> { active_pending } }, if: :active_and_pending
  # validates :user, uniqueness: { conditions: -> { active_processing } }, if: :active_and_processing

  validates :user, uniqueness: { conditions: -> { active_for_later } }, if: :active_and_for_later
  validates :user, uniqueness: { conditions: -> { active_for_now } }, if: :active_and_for_now

  before_destroy :check_for_succesful_charges

  def cart_items_raw_price_cents_combined
    #This is the price before deductions for
    # succesful charges to the cart-items or cart.
    CentsOwedForCartContents.new(self).owed_cents_before_credits
  end

  def subtotal_cents
    #NOTE: Only includes cart-charges when the cart-charges are enough to cover the cost of each item in the cart, less their own direct charges.
    self.cart_items.reduce(0) { |sum, i| sum + i.item_price_in_cents }
  end

  def subtotal_display
    #TODO: Possibly rename along with subtotal_cents
    Money.new(self.subtotal_cents, "USD").format(with_currency: true)
  end

  def items_paid?
    self.subtotal_cents <= 0
  end

  def cents_owed_for_cart_less_all_credits
    CentsOwedForCartContents.new(self).owed_cents
  end

  def active_and_for_later
    self.active? && self.status == FOR_LATER
  end

  def active_and_for_now
    self.active? && self.status == FOR_NOW
  end

  def check_for_succesful_direct_charges
    successes_count = self.charges.inject(0){|a, c| a + ((c.successful? || c.pending?) ? 1 : 0) }
    throw(:abort) if successes_count > 0
  end
end
