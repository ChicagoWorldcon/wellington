class ChangePortionDefaultInReservationCharge < ActiveRecord::Migration[6.0]
  def change
    change_column :reservation_charges, :portion, :integer, default: 0, null: false
  end
end
