# frozen_string_literal: true

# Copyright 2019 AJ Esler
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

# Reservation represents a person who holds a membership
# Reservations have unique "membership_numbers" given out in ascending order
# People are associated to Reservation through Claim which is a join table to User
# Membership details like display name are associated to Reservation through Order which is a join table to Membership
class Reservation < ApplicationRecord
  include Holdable
  include Buyable

  PAID = "paid"
  DISABLED = "disabled"
  INSTALMENT = "instalment"

  has_many :charges, :as => :buyable
  has_many :claims
  has_many :nominations
  has_many :orders
  has_many :ranks

  has_one :cart_item, :as => :holdable
  has_one :active_claim, -> () { active }, class_name: "Claim" # See Claim's validations, one claim active at a time
  has_one :active_order, ->() { active }, class_name: "Order" # See Order's validations, one order active at a time

  has_one :membership, through: :active_order
  has_one :user, through: :active_claim

  # For use in the upgrade process, records the last fully paid membership associated with the reservation.
  has_one :last_fully_paid_membership, :class_name => 'Membership', foreign_key: "last_fully_paid_membership_id"


  # Displayed like "Adult membership #42" is based on #membership_number and Membership#name
  validates :membership_number, presence: true, uniqueness: true

  # Successful charges are used exclusively when determining if a reservation is instalment or paid, and how much is owed
  # This state is set by commands such as ClaimMembership when price is 0, all importers and ApplyCredit
  validates :state, presence: true, inclusion: [PAID, INSTALMENT, DISABLED]

  scope :disabled, -> { where(state: DISABLED) }
  scope :instalment, -> { where(state: INSTALMENT) }
  scope :paid, -> { where(state: PAID) }

  # TODO FUTUREWORLDCON make this more dynamic in the database
  # These are rights that may become visible over time, with the possibility of distinguishing between a right that's
  # currently able to be used or one that's coming soon. These also match i18n values in config/locales
  def active_rights
    [].tap do |rights|
      # Hold these memberships in memory to avoid hitting the database a lot
      memberships_held = Membership.where(id: orders.select(:membership_id))

      rights << "rights.attend" if memberships_held.any?(&:can_attend?)
      rights << "rights.site_selection" if memberships_held.any?(&:can_site_select?)

      now = DateTime.now
      if now < $nomination_opens_at
        if memberships_held.any?(&:can_nominate?)
          rights << "rights.hugo.nominate_soon"
        end
      elsif now.between?($nomination_opens_at, $voting_opens_at)
        if memberships_held.any?(&:can_nominate?) && memberships_held.none?(&:can_vote?)
          rights << "rights.hugo.nominate_only"
        elsif memberships_held.any?(&:can_nominate?)
          rights << "rights.hugo.nominate"
        end
      elsif now.between?($voting_opens_at, $hugo_closed_at)
        if memberships_held.any?(&:can_vote?)
          rights << "rights.hugo.vote"
        end
      end
    end
  end

  # You can nominate if any of your order history had this ability
  # Gets around upgrades after nomination rights are no longer available
  def can_nominate?
    Membership.can_nominate.where(id: orders.select(:membership_id)).exists?
  end

  def can_vote?
    Membership.can_vote.where(id: orders.select(:membership_id)).exists?
  end

  def paid?
    state == PAID
  end

  # Because we don't refund below a supporting membership
  # And because PaymentAmountOptions::MIN_PAYMENT_AMOUNT is equal to a supporting membership
  # We can assume a single successful charge means this membership covers a supporting membership
  def has_paid_supporting?
    charges.successful.any?
  end

  def transferable?
    state != DISABLED
  end

  def instalment?
    state == INSTALMENT
  end

  def disabled?
    state == DISABLED
  end

  # Sync when reservation changes as you might disable or enable rights on a reservation, or have it paid off
  after_commit :gloo_sync
  def gloo_lookup_user
    active_claim&.user
  end
end
