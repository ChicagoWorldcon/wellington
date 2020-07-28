class ReservationCharge < ApplicationRecord
  belongs_to :charge
  belongs_to :reservation

  scope :payment_cleared, -> { joins(:charge).merge(Charge.successful) }

  # monetize :portion_cents, :portion
  monetize :portion_cents


  attr_accessor :portion

  # scope :payment_cleared, -> { joins(:charge).merge(Charge.successful) } do
  #   def sum
  #
  #   end
  # end
end
