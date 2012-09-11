class DisplayedOneFinalTime < ActiveRecord::Migration
  def up
    add_column :task_completions, :displayed_one_final_time, :boolean, :null => false, :default => false
    remove_columns :task_completions, :display_completion_on_next_request
  end

  def down
    remove_columns :task_completions, :displayed_one_final_time
    add_column :task_completions, :display_completion_on_next_request, :boolean, :null => false, :default => false
  end
end
