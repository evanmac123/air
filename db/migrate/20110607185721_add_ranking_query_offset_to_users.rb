class AddRankingQueryOffsetToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :ranking_query_offset, :integer
  end

  def self.down
    remove_column :users, :ranking_query_offset
  end
end
