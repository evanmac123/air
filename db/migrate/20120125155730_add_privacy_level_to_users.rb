class AddPrivacyLevelToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :privacy_level, :string
    execute "UPDATE users SET privacy_level = 'everybody'"
    change_column :users, :privacy_level, :string, :null => false, :default => 'everybody'
    add_index :users, :privacy_level
  end

  def self.down
    remove_column :users, :privacy_level
  end
end
