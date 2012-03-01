class IndexFriendshipsOnStateAndUserId < ActiveRecord::Migration
  def self.up
    remove_index :friendships, :state
    add_index :friendships, [:state, :user_id]
  end

  def self.down
    remove_index :friendships, :column => [:state, :user_id]
    add_index :friendships, :state
  end
end
