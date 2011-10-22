class CreateGoalCompletions < ActiveRecord::Migration
  def self.up
    create_table :goal_completions do |t|
      t.belongs_to :user
      t.belongs_to :goal
      t.timestamps
    end

    add_index :goal_completions, :user_id
    add_index :goal_completions, :goal_id
  end

  def self.down
    drop_table :goal_completions
  end
end
