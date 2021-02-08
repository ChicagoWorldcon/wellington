class Cart < ApplicationRecord
  require 'money'

  PENDING = "pending"
  PAID = "paid"
  STATUS_OPTIONS = [
    PENDING,
    PAID
  ].freeze

  attribute :status, :string, default: PENDING
  validates :status, inclusion: { in: STATUS_OPTIONS }
  belongs_to :user
  has_many :cart_items

  def subtotal_display
    Money.new(self.subtotal_monetized, "USD").format
  end

  def items_for_now
    CartItemsHelper.cart_items_for_now(self)
  end

  def items_for_later
    CartItemsHelper.cart_items_for_later(self)
  end

  def all_items_count
    self.cart_items.count
  end

  private

  def subtotal_monetized
    monetized = 0
    talliables = self.items_for_now
    if talliables.count > 0
      talliables.each do |item|
        monetized += item.item_price_in_cents
      end
    end
    monetized
  end
end
