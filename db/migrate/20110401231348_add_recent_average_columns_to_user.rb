class AddRecentAverageColumnsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :recent_average_points, :integer, :null => false, :default => 0
    add_column :users, :recent_average_ranking, :integer, :null => false, :default => 0
    add_column :users, :recent_average_history_depth, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :users, :recent_average_history_depth
    remove_column :users, :recent_average_ranking
    remove_column :users, :recent_average_points
  end
end
