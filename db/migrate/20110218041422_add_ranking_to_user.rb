class AddRankingToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :ranking, :integer
  end

  def self.down
    remove_column :user, :ranking
  end
end
