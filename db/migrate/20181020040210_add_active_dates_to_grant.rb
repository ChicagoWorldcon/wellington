class AddActiveDatesToGrant < ActiveRecord::Migration[5.1]
  def change
    add_column :grants, :active_from, :timestamp, null: false
    add_column :grants, :active_to, :timestamp
  end
end
