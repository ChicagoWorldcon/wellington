class CanonicalizeEmail < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :user_provided_email, :string
    execute "UPDATE users SET user_provided_email = email"

    User.all.each do |user|
      curr_email = user.user_provided_email
      user.email = curr_email
      user.save
    end
  end

  def down
    execute "UPDATE users SET email = user_provided_email"
    remove_column :users, :user_provided_email
  end
end
