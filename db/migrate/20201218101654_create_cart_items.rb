class CreateCartItems < ActiveRecord::Migration[6.1]
  def change
    create_table :cart_items do |t|
      t.references :cart, index: true, null: false, foreign_key: true
      t.references :membership, index: true, null: true, foreign_key: true
      t.references :chicago_contact, index: true, null: true, foreign_key: true
      t.monetize :price_cents
      t.timestamps
    end
  end
end
