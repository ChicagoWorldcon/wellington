class AddDateOfBirthToChicagoContact < ActiveRecord::Migration[6.0]
  def change
    add_column :chicago_contacts, :date_of_birth, :date
  end
end
