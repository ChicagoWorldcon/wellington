class AddOfferLockDateToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :offer_lock_date, :datetime,  null: true
  end
end
