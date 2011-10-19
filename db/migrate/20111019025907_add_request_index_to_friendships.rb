class AddRequestIndexToFriendships < ActiveRecord::Migration
  def self.up
    add_column :friendships, :request_index, :integer
    add_index :friendships, :request_index
  end

  def self.down
    remove_column :friendships, :request_index
  end
end
