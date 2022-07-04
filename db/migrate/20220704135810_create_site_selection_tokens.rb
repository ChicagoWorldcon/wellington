class CreateSiteSelectionTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :site_selection_tokens do |t|
      t.string :token
      t.string :voter_id
      t.string :election

      t.timestamps
    end
    add_index :site_selection_tokens, :token, unique: true
    add_index :site_selection_tokens, :voter_id, unique: true
  end
end
