class ReservationCharge < ApplicationRecord
  belongs_to :charge
  belongs_to :reservation

  scope :payment_cleared, -> { joins(:charge).merge(Charge.successful) }

  monetize :portion_cents
end
