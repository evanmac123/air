class RenamedTaskSuggestionsTaskCompletions < ActiveRecord::Migration
  def up
    rename_table :task_suggestions, :task_completions
  end

  def down
    rename_table :task_completions, :task_suggestions
  end
end
