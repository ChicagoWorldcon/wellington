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

  def subtotal_display
    binding.pry
    Money.new(self.subtotal_monetized, "USD").format
  end

  private

  def subtotal_monetized
    binding.pry
    monetized = 0
    binding.pry
    talliables = CartItemsHelper.cart_items_for_now(self)
    binding.pry
    if talliables.count > 0
      talliables.each do |item|
        binding.pry
        monetized += item.item_monetized_price
      end
    end
    binding.pry
    kittens = "kittens"
    monetized
  end


end
