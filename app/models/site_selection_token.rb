class SiteSelectionToken < ApplicationRecord
  belongs_to :token_purchase, optional: true

  scope :for_election, ->(election) { where("election = ?", election) }
  scope :unclaimed, -> { where.not(id: TokenPurchase.pluck(:site_selection_token_id).reject(&:nil?)) }

  validates :voter_id, uniqueness: { scope: :election, message: "should be unique per election" }

  def self.elections
    self.select(:election).distinct.pluck(:election)
  end
end
