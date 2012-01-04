class AddBonusPointsToTaskSuggestions < ActiveRecord::Migration
  def self.up
    add_column :suggested_tasks, :bonus_points, :integer, :null => false, :default => 0
  end

  def self.down
    remove_columns :suggested_tasks, :bonus_points
  end
end
