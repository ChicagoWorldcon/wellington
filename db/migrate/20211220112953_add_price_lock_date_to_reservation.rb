class AddPriceLockDateToReservation < ActiveRecord::Migration[6.1]
  def change
    add_column :reservations, :price_lock_date, :datetime
  end
end
