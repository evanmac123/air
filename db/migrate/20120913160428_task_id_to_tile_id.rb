class TaskIdToTileId < ActiveRecord::Migration
  def up
    rename_column :tile_completions, :task_id, :tile_id
  end

  def down
    rename_column :tile_completions, :tile_id, :task_id
  end
end
