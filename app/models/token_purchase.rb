class TokenPurchase < ApplicationRecord
  belongs_to :site_selection_token
  belongs_to :reservation

  def self.for_election!(reservation, election)
    SiteSelectionToken.transaction do
      unclaimed = SiteSelectionToken.for_election(election).unclaimed.first
      create!(reservation: reservation, site_selection_token: unclaimed)
    end
  end
end
