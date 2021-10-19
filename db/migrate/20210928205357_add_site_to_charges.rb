class AddSiteToCharges < ActiveRecord::Migration[6.1]
  def change
    add_column :charges, :site, :boolean
  end
end
