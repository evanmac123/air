class AddSatisfiedFlagToTaskSuggestion < ActiveRecord::Migration
  def self.up
    add_column :task_suggestions, :satisfied, :boolean, :null => false, :default => false
    add_index :task_suggestions, :satisfied
  end

  def self.down
    remove_column :task_suggestions, :satisfied
  end
end
