class CreateSiteTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :site_tokens do |t|
      t.integer :membership_number
      t.string :token

      t.timestamps
    end
  end
end
