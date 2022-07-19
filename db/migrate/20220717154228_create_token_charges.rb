class CreateTokenCharges < ActiveRecord::Migration[6.1]
  def change
    create_table :token_charges do |t|
      t.references :token_purchase, null: false, foreign_key: true
      t.string :charge_id, null: false
      t.string :charge_provider, null: false
      t.timestamps
    end

    add_monetize :token_charges, :price
  end
end
