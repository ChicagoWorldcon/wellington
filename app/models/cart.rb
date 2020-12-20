class Cart < ApplicationRecord
  PENDING = "pending"
  STATUS_OPTIONS = [
    PENDING
    #DONATION,
    #UPGRADE
  ].freeze

  validates :status, inclusion: { in: STATUS_OPTIONS }
  belongs_to :user
  has_many :cart_items

  def subtotal 
  end
end
