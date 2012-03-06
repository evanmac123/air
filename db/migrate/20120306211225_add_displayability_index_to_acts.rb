class AddDisplayabilityIndexToActs < ActiveRecord::Migration
  def self.up
    add_index :acts, [:hidden, :demo_id, :user_id, :privacy_level]
    remove_index :acts, :hidden
    remove_index :acts, :demo_id
    remove_index :acts, :privacy_level
  end

  def self.down
    add_index :acts, :demo_id
    add_index :acts, :hidden
    add_index :acts, :privacy_level
    remove_index :acts, :column => [:hidden, :demo_id, :user_id, :privacy_level]
  end
end
