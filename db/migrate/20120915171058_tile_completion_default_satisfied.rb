class TileCompletionDefaultSatisfied < ActiveRecord::Migration
  def up
    change_column :tile_completions, :satisfied, :boolean, :null => false, :default => true
  end

  def down
    change_column :tile_completions, :satisfied, :boolean, :null => false, :default => false 
  end
end
