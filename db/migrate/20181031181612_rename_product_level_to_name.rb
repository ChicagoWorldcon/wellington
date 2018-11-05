class RenameProductLevelToName < ActiveRecord::Migration[5.1]
  def change
    rename_column :products, :level, :name
  end
end
