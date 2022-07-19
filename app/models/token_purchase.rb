class TokenPurchase < ApplicationRecord
  belongs_to :site_selection_token
  belongs_to :reservation
  has_one :token_charge

  def self.for_election!(reservation, election)
    SiteSelectionToken.transaction do
      unclaimed = SiteSelectionToken.for_election(election).unclaimed.first
      create!(reservation: reservation, site_selection_token: unclaimed)
    end
  end

  scope :unpaid, -> { where.missing(:token_charge) }
  scope :paid, -> { joins(:token_charge).where("token_charges.id is not null") }

  def paid_for?
    token_charge.present?
  end

  def charge_stripe!(charge_id:, price_cents:)
    update!(token_charge: TokenCharge.create(
      charge_id: charge_id,
      charge_provider: "stripe",
      price_cents: price_cents
    ))
  end
end
