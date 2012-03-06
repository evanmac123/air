class AddDisplayabilityIndexToActs < ActiveRecord::Migration
  def self.up
    add_index :acts, [:hidden, :demo_id, :user_id, :privacy_level]
  end

  def self.down
    remove_index :acts, :column => [:hidden, :demo_id, :user_id, :privacy_level]
  end
end
