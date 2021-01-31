# frozen_string_literal: true

# Copyright 2020 Victoria Garcia
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

# A CartItem is a potential reservation (or a donation, or anything else That
# the reg site might sell in the future) that is being held in the cart pending
# payment.
class CartItem < ApplicationRecord

  monetize :item_price_cents
  # Support for donations and upgrades is coming later.  This is just
  # meant as a hint for the future about how to make that happen.

  MEMBERSHIP = "membership"
  # DONATION = "donation"
  # UPGRADE = "upgrade"

  KIND_OPTIONS = [
    MEMBERSHIP
    #DONATION,
    #UPGRADE
  ].freeze


  belongs_to :cart
  # Once there are type options other than membership, the 'required'
  # values of :membership and :chicago_contact will need to change, both here
  # and in the database.
  belongs_to :membership, required: true
  belongs_to :chicago_contact, required: true
  validates :kind, inclusion: { in: KIND_OPTIONS }
  validates :item_name, presence: true
  validates :item_price_cents, presence: true
  validates :available, presence: true

  # TODO: Figure out how these should interact with the
  # availability confirmation scheme.
  def item_display_name
    if self.kind == MEMBERSHIP
      return membership_display_name
    end
  end

  def item_display_price
    if self.kind == MEMBERSHIP
      return membership_display_price
    end
  end

  def item_monetized_price
    if self.kind == MEMBERSHIP
      return membership_monetized_price
    end
  end

  def item_recipient
    if self.kind == MEMBERSHIP
      return membership_recipient_name
    end
  end

  def confirm_item_availability
    # Written with this conditional to allow for later
    # addition of cart-items that aren't memberships.
    binding.pry
    if self.kind == MEMBERSHIP
      binding.pry
      active_membership = Membership.active.where(id: self.membership_id, name: self.item_name, price_cents: self.item_price_cents)
      binding.pry
      self.available = active_membership.present? && active_membership.count == 1
      self.save
    end
    binding.pry
    return self.available
  end

  private

  # TODO: Go through all this display stuff and make sure it still makes sense,
  # given that we're going to save the membership name and price

  def membership_display_name
    @item_membership ||= find_membership
    binding.pry
    @item_membership.name_for_cart
  end

  def membership_display_price
    @item_membership ||= find_membership
    @item_membership.display_price_for_cart
  end

  def membership_monetized_price
    @item_membership ||= find_membership
    @item_membership.monetized_price_for_cart
  end

  def membership_recipient_name
    @item_recipient ||= find_recipient
    @item_recipient.name_for_cart
  end

  def find_membership
    binding.pry
    @item_membership = Membership.find(membership_id)
  end

  # TODO: Make this con-agnostic so that this doesn't have to be changed
  # in hard-code every year.
  def find_recipient
    binding.pry
    @item_recipient = ChicagoContact.find(chicago_contact_id)
  end
end
