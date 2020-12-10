class CreateCartSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :cart_sessions do |t|

      t.timestamps
    end
  end
end
