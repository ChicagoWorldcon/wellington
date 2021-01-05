class Cart < ApplicationRecord
  require 'money'

  PENDING = "pending"
  PAID = "paid"
  STATUS_OPTIONS = [
    PENDING,
    PAID
  ].freeze

  validates :status, inclusion: { in: STATUS_OPTIONS }
  belongs_to :user
  has_many :cart_items

  def subtotal_monetized
    binding.pry
    talliables = CartItemsHelper.cart_items_for_now(self)
    binding.pry
    monetized = 0
    talliables.each do |item|
      monetized += item.item_monetized_price
    end
    binding.pry
    kittens = "kittens"
    monetized
  end

  def subtotal_display
    binding.pry
    Money.new(self.subtotal_monetized, "USD").format
  end
end
