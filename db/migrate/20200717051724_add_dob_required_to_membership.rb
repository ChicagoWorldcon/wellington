class AddDobRequiredToMembership < ActiveRecord::Migration[6.0]
  def change
    add_column :memberships, :dob_required, :boolean, default: false, null: false
  end
end
