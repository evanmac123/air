class SplitUserIdAndPrivacyLevelFromDisplayabilityIndex < ActiveRecord::Migration
  def self.up
    remove_index :acts, [:hidden, :demo_id, :user_id, :privacy_level]
    add_index :acts, [:hidden, :demo_id]
    add_index :acts, :privacy_level

    # player_id index already exists
  end

  def self.down
    # player_id index already exists

    remove_index :acts, :column => :privacy_level
    remove_index :acts, :column => [:hidden, :demo_id]
    add_index :acts, [:hidden, :demo_id, :user_id, :privacy_level]
  end
end
