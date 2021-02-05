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

# A CartItem is a potential reservation (or a donation, or anything else That
# the reg site might sell in the future) that is being held in the cart pending
# payment.
class CartItem < ApplicationRecord
  include ThemeConcern

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

  # :benefitable, here, is a polymorphic association
  # with the theme_contact_class. It represents
  # the person whose name will be on the membership. (So,
  # it's distinct from the :user who owns the :cart and
  # will be making the purchase.  (It's also meant to be
  # distinct from any shipping-related stuff we may have
  # in the future.)
  #     Note that we're allowing it to be optional because
  # only memberships (and upgrades) will need this
  # attribute. T-shirts, etc., will not. Note also that it
  # has a special, funky validator below to prevent that choice
  # from ushering in the reign of chaos.
  belongs_to :benefitable, :polymorphic => true, required: false

  # :acquirable, here, is a polymorphic association
  # with whatever the item that's being bought is.
  # At the moment, the only acquirable a membership,
  # but we expect that eventually there may be t-shirts and the
  # like.
  belongs_to :acquirable, :polymorphic => true, required: true

  attribute :available, :boolean, default: true
  attribute :later, :boolean, default: true

  validates :item_name, presence: true
  validates :item_price_cents, presence: true
  validates :kind, inclusion: { in: KIND_OPTIONS }
  validates :benefitable, presence: true, if: Proc.new { |item| item.kind == MEMBERSHIP }

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

  def item_beneficiary
    if self.kind == MEMBERSHIP
      return membership_beneficiary_name
    end
  end

  def item_still_available?
    confirmed = self.available
    # Written with this conditional to allow for later
    # addition of cart-items that aren't memberships.

    # TODO: See if this can be better accomplished
    # with the ActiveScopes concern. NB-- right now,
    # I feel like it's kind of good the way it is.
    if self.kind == MEMBERSHIP
      confirmed = (
        confirmed &&
        self.acquirable.active? &&
        Membership.active.where(
          id: self.acquirable_id,
          name: self.item_name,
          price_cents: self.item_price_cents).present?
        )
    end
    self.available = confirmed
    self.save
    self.available
  end

  private

  # TODO: Go through all this display stuff and make sure it still makes sense.

  def membership_display_name
    self.acquirable.name_for_cart if self.kind == MEMBERSHIP
  end

  def membership_display_price
    self.acquirable.display_price_for_cart if self.kind == MEMBERSHIP
  end

  def membership_monetized_price
    self.acquirable.monetized_price_for_cart if self.kind == MEMBERSHIP
  end

  def membership_beneficiary_name
    self.benefitable.name_for_cart if self.kind == MEMBERSHIP
  end

  def find_membership
    self.acquirable if self.kind == MEMBERSHIP
  end

  def find_beneficiary
    self.benefitable if self.kind == MEMBERSHIP
  end
end
