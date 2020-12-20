class CreateCarts < ActiveRecord::Migration[6.1]
  def change
    create_table :carts do |t|
      t.references :user, index: true, null: false, foreign_key: true
      t.string :status, null: false,
      t.timestamps
    end
  end
end
