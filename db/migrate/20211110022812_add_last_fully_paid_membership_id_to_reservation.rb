class AddLastFullyPaidMembershipIdToReservation < ActiveRecord::Migration[6.1]
  def change
    add_column :reservations, :last_fully_paid_membership_id, :integer
  end
end
