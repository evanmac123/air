class RemoveConnectionBountyFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :connection_bounty
  end

  def down
    add_column :users, :connection_bounty, :integer, :default => 0
  end
end
