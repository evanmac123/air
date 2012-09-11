class RenamedTaskToTile < ActiveRecord::Migration
  def up
    rename_table :tasks, :tiles
    rename_table :task_completions, :tile_completions
  end

  def down
    rename_table :tiles, :tasks
    rename_table :tile_completions, :task_completions
  end
end
