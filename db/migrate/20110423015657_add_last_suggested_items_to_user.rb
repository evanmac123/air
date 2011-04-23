class AddLastSuggestedItemsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :last_suggested_items, :string, :null => false, :default => ''
  end

  def self.down
    remove_column :users, :last_suggested_items
  end
end
