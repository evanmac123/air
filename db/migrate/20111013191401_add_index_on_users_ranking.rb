class AddIndexOnUsersRanking < ActiveRecord::Migration
  def self.up
    add_index :users, :ranking
  end

  def self.down
    remove_index :users, :column => :ranking
  end
end
