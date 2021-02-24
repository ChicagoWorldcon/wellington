class Cart < ApplicationRecord
  require 'money'
  include Buyable

  PENDING = "pending"
  PAID = "paid"
  STATUS_OPTIONS = [
    PENDING,
    PAID
  ].freeze

  attribute :status, :string, default: PENDING
  validates :status, presence: true, :inclusion => { in: STATUS_OPTIONS }
  belongs_to :user
  has_many :charges, :as => :buyable
  has_many :cart_items

  def subtotal_cents
    subtotal = 0
    talliables = self.items_for_now
    talliables.each { |t|
      subtotal += t.item_price_in_cents if t.item_still_available? }
    subtotal
  end

  def subtotal_display
    Money.new(self.subtotal_cents, "USD").format
  end

  def items_for_now
    CartItemsHelper.cart_items_for_now(self)
  end

  def items_for_later
    CartItemsHelper.cart_items_for_later(self)
  end
end
