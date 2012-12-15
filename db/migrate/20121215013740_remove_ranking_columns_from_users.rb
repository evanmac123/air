class RemoveRankingColumnsFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :recent_average_history_depth
    remove_column :users, :recent_average_points
    remove_column :users, :recent_average_ranking
    remove_column :users, :ranking
  end

  def down
    add_column :users, :ranking, :integer, :null => false, :default => 0
    add_column :users, :recent_average_ranking, :integer, :null => false, :default => 0
    add_column :users, :recent_average_points, :integer, :null => false, :default => 0
    add_column :users, :recent_average_history_depth, :integer, :null => false, :default => 0
  end
end
