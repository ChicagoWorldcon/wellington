class CreateTemporaryUserTokens < ActiveRecord::Migration[6.1]
  def change
    create_table :temporary_user_tokens do |t|
      t.string :shortcode
      t.string :token
      t.datetime :active_from, null: false
      t.datetime :active_to, null: false

      t.timestamps
    end
  end
end
