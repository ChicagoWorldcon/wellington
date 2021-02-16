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

  # Support for donations and upgrades is coming later.  This is just
  # meant as a hint for the future about how to make that happen.
  MEMBERSHIP = "membership"
  UNKNOWN = "unknown"
  # DONATION = "donation"
  # UPGRADE = "upgrade"

  KIND_OPTIONS = [
    MEMBERSHIP,
    UNKNOWN
    #DONATION,
    #UPGRADE
  ].freeze

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
  # like.  Donations and upgrades would also be forms of :acquirable, if we made them addable to the cart.
  belongs_to :acquirable, :polymorphic => true, required: true
  belongs_to :cart

  attribute :available, :boolean, default: true
  attribute :later, :boolean, default: false
  attribute :incomplete, :boolean, default: false

  before_validation :note_acquirable_details, if: :new_record?

  validates :available, :inclusion => {in: [true, false]}
  validates :benefitable, presence: true, if: Proc.new { |item| item.kind == MEMBERSHIP }
  validates :incomplete, :inclusion => {in: [true, false]}
  # :item_name_memo and :item_price_memo exist to record the
  # name and price of an acquirable at the time it was added to the
  # cart by the user.  Stripe and the like should not use these.
  # Those should, instead, use the information from the acquirable object
  validates :item_name_memo, presence: true
  validates :item_price_memo, presence: true
  validates_numericality_of :item_price_memo
  validates :kind, presence: true, :inclusion => { in: KIND_OPTIONS }
  validates :later, :inclusion => {in: [true, false]}


  # TODO: Figure out how these should interact with the
  # availability confirmation scheme.
  def item_display_name
    case self.kind
    when MEMBERSHIP
      membership_display_name
    else
      UNKNOWN
    end
  end

  def item_display_price
    case self.kind
    when MEMBERSHIP
      membership_display_price
    else
      Money.new(0, "USD").format(with_currency: true)
    end
  end

  def item_price_in_cents
    case self.kind
    when MEMBERSHIP
      membership_price_in_cents
    else
      0
    end
  end

  def item_beneficiary_name
    case self.kind
    when MEMBERSHIP
      membership_beneficiary_name
    else
      ""
    end
  end

  def item_still_available?
    # Note: This is currently written so as to make unavailability a
    # permanent condition. Once something has become unavailable, it
    # never becomes available again.   That, of course, is something
    # that could be changed easily later on, as requirements change.


    # TODO: See if this can be better accomplished
    # with the ActiveScopes concern. NB-- right now,
    # I feel like it's kind of good the way it is.
  confirmed = (
    self.available &&
    self.item_display_name != UNKNOWN &&
    self.acquirable.active? &&
    self.acquirable_type.constantize.active.where(
      id: self.acquirable_id,
      name: self.item_name_memo,
      price_cents: self.item_price_memo
      ).present?
    )
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

  def membership_price_in_cents
    self.acquirable.price_in_cents_for_cart if self.kind == MEMBERSHIP
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

  def note_acquirable_details
    # These aren't actually the details that will be used for Stripe and
    # creation of a Charge.
    # They're strictly here as a failsafe mechanism:  if
    # something gets put in someone's cart and then sits there for
    # three months, having these details logged means we can
    # make sure that there haven't been meaningful changes
    # to the associated acquirable in the interim.
    self.item_price_memo = self.acquirable.price_cents
    self.item_name_memo = self.acquirable.name
  end
end
