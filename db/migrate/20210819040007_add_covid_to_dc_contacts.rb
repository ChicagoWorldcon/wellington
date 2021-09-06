class AddCovidToDcContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :dc_contacts, :covid, :boolean, null: true
  end
end
