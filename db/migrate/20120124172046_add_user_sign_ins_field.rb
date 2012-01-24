class AddUserSignInsField < ActiveRecord::Migration
  def self.up
    add_column :users, :session_count, :integer
    execute "update users set session_count = 100"
    change_column :users, :session_count, :integer, :null => false, :default => 0
  end

  def self.down
    remove_columns :users, :session_count
  end
end
