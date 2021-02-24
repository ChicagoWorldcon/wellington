class UsePolymorphicAssociationInCharge < ActiveRecord::Migration[6.1]
  def up
    add_reference :charges, :buyable, polymorphic: true, index: true, null: true
    Charge.update_all("buyable_id = reservation_id, buyable_type = 'Reservation'")
    remove_reference :charges, :reservation, index: true, foreign_key: true
  end

  def down
    add_reference :charges, :reservation, index: true, foreign_key: true, null: true
    Charge.update_all("reservation_id = buyable_id")
    change_column_null :charges, :reservation_id, :false
    remove_reference :charges, :buyable, polymorphic: true, index: true, null: true
  end
end
