class AddUsersLastLoadedToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :users_last_loaded, :timestamp
  end
end
