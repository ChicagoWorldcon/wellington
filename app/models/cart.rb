class Cart < ApplicationRecord
  require 'money'
  include Buyable
  include ActiveScopes

  FOR_LATER = "for_later"
  PENDING = "pending"
  PROCESSING = "processing"
  AWAITING_CHEQUE = "awaiting_cheque"
  PAID = "paid"

  STATUS_OPTIONS = [
    FOR_LATER,
    PENDING,
    PROCESSING,
    AWAITING_CHEQUE,
    PAID
  ].freeze

  attribute :status, :string, default: PENDING
  validates :status, presence: true, :inclusion => { in: STATUS_OPTIONS }
  belongs_to :user
  has_many :charges, :as => :buyable
  has_many :cart_items

  # A user has one active cart at a time
  # TODO:  WRITE A CUSTOM VALIDATOR SO THAT A USER CAN HAVE:
  # One active, pending cart; one active, processing cart; infinite paid and/or inactive carts
  validates :user, uniqueness: { conditions: -> { active_pending } }, if: :active_and_pending
  validates :user, uniqueness: { conditions: -> { active_processing } }, if: :active_and_processing
  validates :user, uniqueness: { conditions: -> { active_for_later } }, if: :active_and_for_later


  def subtotal_cents
    subtotal = 0
    talliables = self.items_for_now
    talliables.each { |t|
      subtotal += t.item_price_in_cents if t.item_still_available? }
    subtotal
  end

  def subtotal_display
    Money.new(self.subtotal_cents, "USD").format(with_currency: true)
  end

  def items_for_now
    CartItemsHelper.cart_items_for_now(self)
  end

  def items_for_later
    CartItemsHelper.cart_items_for_later(self)
  end

  def active_and_pending
    self.active? && self.status == PENDING
  end

  def active_and_processing
    self.active? && self.status == PROCESSING
  end

  def active_and_for_later
    self.active? && self.status == FOR_LATER
  end
end
