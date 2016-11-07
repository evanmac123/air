class AddUniqueIndexToUsers < ActiveRecord::Migration
  def up
    remove_index "users", :name => "index_users_on_official_email"

    add_index "users", :official_email, unique: true
    add_index "users", :email, unique: true
  end

  def down
    remove_index "users", :official_email
    remove_index "users", :email
    
    add_index "users", :official_email
  end
end
