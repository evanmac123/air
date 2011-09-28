class AddIndicesToLevelsUsers < ActiveRecord::Migration
  def self.up
    add_index :levels_users, :level_id
    add_index :levels_users, :user_id
  end

  def self.down
    remove_index :levels_users, :column => :user_id
    remove_index :levels_users, :column => :level_id
  end
end
