class AddStateToFriendships < ActiveRecord::Migration
  def self.up
    add_column :friendships, :state, :string
    execute "UPDATE friendships SET state='accepted'"
    change_column :friendships, :state, :string, :null => false, :default => 'pending'
    add_index :friendships, :state
  end

  def self.down
    remove_column :friendships, :state
  end
end
