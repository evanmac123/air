class RemovedSatisfiedFromTileCompletion < ActiveRecord::Migration
  def up 
    remove_columns :tile_completions, :satisfied
  end

  def down
    add_column :tile_completions, :satisfied, :boolean, :null => false, :default => true
  end
end
