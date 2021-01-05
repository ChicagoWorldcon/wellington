class RemoveNullConstraintFromChicagoContact < ActiveRecord::Migration[6.1]
  def change
    change_column_null :chicago_contacts, :claim_id, :true
  end
end
