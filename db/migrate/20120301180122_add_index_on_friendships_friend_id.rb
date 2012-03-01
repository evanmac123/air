class AddIndexOnFriendshipsFriendId < ActiveRecord::Migration
  def self.up
    add_index :friendships, :friend_id
  end

  def self.down
    remove_index :friendships, :column => :friend_id
  end
end
