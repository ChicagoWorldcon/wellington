class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items
  validates :status, presence: true
end
