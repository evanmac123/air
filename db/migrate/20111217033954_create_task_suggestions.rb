class CreateTaskSuggestions < ActiveRecord::Migration
  def self.up
    create_table :task_suggestions do |t|
      t.belongs_to :suggested_task
      t.belongs_to :user
      t.timestamps
    end

    add_index :task_suggestions, :suggested_task_id
    add_index :task_suggestions, :user_id
  end

  def self.down
    drop_table :task_suggestions
  end
end
