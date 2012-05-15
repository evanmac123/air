class RenameSuggestedTaskToJustTask < ActiveRecord::Migration
  def self.up
    rename_table :suggested_tasks, :tasks
  end

  def self.down
    rename_table :tasks, :suggested_tasks
  end
end
