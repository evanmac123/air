class AddIndexToUserSlug < ActiveRecord::Migration
  def self.up
    add_index :users, :slug
  end

  def self.down
    remove_index :users, :column => :slug
  end
end
