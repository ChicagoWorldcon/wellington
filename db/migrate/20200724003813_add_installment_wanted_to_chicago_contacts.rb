class AddInstallmentWantedToChicagoContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :chicago_contacts, :installment_wanted, :boolean, default: false, null: false
  end
end
