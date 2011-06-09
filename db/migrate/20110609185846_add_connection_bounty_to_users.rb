class AddConnectionBountyToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :connection_bounty, :integer, :default => 0
    change_column_null :users, :connection_bounty, false, 0
  end

  def self.down
    remove_column :users, :connection_bounty
  end
end
