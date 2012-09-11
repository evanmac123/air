class ChangePrerequisiteTaskToPrerequisiteTile < ActiveRecord::Migration
  def up
    rename_column :prerequisites, :prerequisite_task_id, :prerequisite_tile_id
    rename_column :prerequisites, :task_id, :tile_id
  end

  def down
    rename_column :prerequisites, :prerequisite_tile_id, :prerequisite_task_id
    rename_column :prerequisites, :tile_id, :task_id
  end
end
