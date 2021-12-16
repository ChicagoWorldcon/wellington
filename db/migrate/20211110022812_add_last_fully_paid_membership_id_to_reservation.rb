class AddLastFullyPaidMembershipIdToReservation < ActiveRecord::Migration[6.1]
  def change
    add_belongs_to :reservations, :last_fully_paid_membership, foreign_key: {to_table: :memberships}, null: true
  end
end
