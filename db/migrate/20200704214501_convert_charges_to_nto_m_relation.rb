class ConvertChargesToNtoMRelation < ActiveRecord::Migration[6.0]
  def change
    create_table :reservation_charges do |t|
      t.references :reservation, index: true, null: false, foreign_key: true
      t.references :charge, index: true, null: false, foreign_key: true
      t.column :portion, :integer, null: false
      t.monetize :portion
    end
  end
end
