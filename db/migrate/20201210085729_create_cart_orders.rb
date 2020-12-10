class CreateCartOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :cart_orders do |t|

      t.timestamps
    end
  end
end
