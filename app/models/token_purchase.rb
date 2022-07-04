class TokenPurchase < ApplicationRecord
  belongs_to :site_selection_token
  belongs_to :reservation
end
