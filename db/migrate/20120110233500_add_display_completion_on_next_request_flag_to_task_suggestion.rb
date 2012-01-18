class AddDisplayCompletionOnNextRequestFlagToTaskSuggestion < ActiveRecord::Migration
  def self.up
    add_column :task_suggestions, :display_completion_on_next_request, :boolean
    execute "UPDATE task_suggestions SET display_completion_on_next_request=false"
    change_column :task_suggestions, :display_completion_on_next_request, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :task_suggestions, :display_completion_on_next_request
  end
end
