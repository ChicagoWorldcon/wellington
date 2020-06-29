class AddMailSouvenirBookToChicagoContacts < ActiveRecord::Migration[6.0]
  def change
    add_column :chicago_contacts, :mail_souvenir_book, :boolean
  end
end
