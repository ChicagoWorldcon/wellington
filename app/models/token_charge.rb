class TokenCharge < ApplicationRecord
  belongs_to :token_purchase

  monetize :price_cents
end
