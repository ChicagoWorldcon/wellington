class CreateTokenPurchases < ActiveRecord::Migration[6.1]
  def change
    create_table :token_purchases do |t|
      t.references :site_selection_token, null: false, foreign_key: true, unique: true
      t.references :reservation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
