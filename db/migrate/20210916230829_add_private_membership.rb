class AddPrivateMembership < ActiveRecord::Migration[6.1]
  def up
    add_column :memberships, :private_membership_option, :boolean, default: false, null: false
  end

  def down
    remove_column :memberships, :private_membership_option
  end
end
