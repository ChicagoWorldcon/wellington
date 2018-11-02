class RemoveCategoryFromMembership < ActiveRecord::Migration[5.1]
  def change
    remove_column :memberships, :category
  end
end
