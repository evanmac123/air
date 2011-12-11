class AddStartTimeToSuggestedTasks < ActiveRecord::Migration
  def self.up
    add_column :suggested_tasks, :start_time, :datetime
    add_index :suggested_tasks, :start_time
  end

  def self.down
    remove_column :suggested_tasks, :start_time
  end
end
