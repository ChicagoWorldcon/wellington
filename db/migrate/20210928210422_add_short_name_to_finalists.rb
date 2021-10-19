class AddShortNameToFinalists < ActiveRecord::Migration[6.1]
  def change
    add_column :finalists, :short_name, :string
  end
end
