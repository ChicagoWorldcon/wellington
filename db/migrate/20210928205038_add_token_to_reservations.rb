class AddTokenToReservations < ActiveRecord::Migration[6.1]
  def change
    add_column :reservations, :token, :string
  end
end
