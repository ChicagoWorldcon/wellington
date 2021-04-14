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

  # :holdable refers to a piece of digital property created
  # through purchase of the cart item. As of this writing,
  # Reservations are the only Holdables we have, but other examples
  # might include site-selection tokens, tickets for special events,
  # etc.
  belongs_to :holdable, :polymorphic => true, required: false

  belongs_to :cart
  has_one :user, through: :cart

  attribute :available, :boolean, default: true
  attribute :later, :boolean, default: false
  attribute :incomplete, :boolean, default: false
  #attribute :processed, :boolean, default: false

  before_validation :note_acquirable_details, if: :new_record?
  before_validation :set_kind_value, if: :new_record?

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
  #validates :processed, :inclusion => {in: [true, false]}


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

  def item_unique_id_for_laypeople
    case self.kind
    when MEMBERSHIP
      membership_unique_for_laypeeps
    else
      nil
    end
  end

  def quick_description
    subj_str = "#{self.item_display_name} #{self.kind}"
    obj_str = self.benefitable ? " for #{self.shortened_item_beneficiary_name}" : ""
    subj_str + obj_str
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
      if self.item_reservation
        AmountOwedForReservation.new(self.holdable).amount_owed.cents
      else
        membership_price_in_cents
      end
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

  def shortened_item_beneficiary_name
    case self.kind
    when MEMBERSHIP
      shortened_membership_beneficiary_name
    else
      ""
    end
  end

  def item_ready_for_payment?
    ready = confirm_availability
    if self.kind == MEMBERSHIP
      ready = ready && confirm_beneficiary
    end
    ready
  end

  def item_reservation
    item_res = (self.holdable.present? && self.holdable.kind_of?(Reservation)) ? self.holdable : nil
  end

  def item_still_available?
    confirm_availability
  end

  def membership_cart_item_is_valid?
    #TODO: Maybe make some kind of informative error situation here.
    valid = self.acquirable.kind_of?(Membership)
    if valid
      valid = false unless self.benefitable.present? && self.benefitable.valid?
      valid = false unless self.acquirable.present? && self.acquirable.active?
    end
    valid
  end

  private

  # TODO: Go through all this display stuff and make sure it still makes sense.

  def membership_display_name
    self.acquirable.name_for_cart if self.kind == MEMBERSHIP
  end

  def membership_display_price
    if self.kind == MEMBERSHIP
      if self.item_reservation
        AmountOwedForReservation.new(self.item_reservation).amount_owed.format(with_currency: true)
      else
        self.acquirable.display_price_for_cart
      end
    end
  end

  def membership_price_in_cents
    self.acquirable.price_in_cents_for_cart if self.kind == MEMBERSHIP
  end

  def membership_beneficiary_name
    self.benefitable.name_for_cart if self.kind == MEMBERSHIP
  end

  def shortened_membership_beneficiary_name
    self.benefitable.shortened_display_name if self.kind == MEMBERSHIP
  end

  def find_membership
    self.acquirable if self.kind == MEMBERSHIP
  end

  def find_beneficiary
    self.benefitable if self.kind == MEMBERSHIP
  end

  def confirm_beneficiary
    confirmed_beneficiary = false
    if self.benefitable.present?
      confirmed_beneficiary = self.benefitable.valid?
    end
    confirmed_beneficiary
  end

  def confirm_availability
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

  def set_kind_value
    case self.acquirable_type
    when "Membership"
      self.kind = MEMBERSHIP
    else
      self.kind = UNKNOWN
    end
  end

  def membership_unique_for_laypeeps
    return nil if self.kind != MEMBERSHIP
    self.item_reservation ? self.item_reservation.membership_number : nil
  end
end
