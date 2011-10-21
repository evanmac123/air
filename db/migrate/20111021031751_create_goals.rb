class CreateGoals < ActiveRecord::Migration
  def self.up
    create_table :goals do |t|
      t.string :name, :null => false, :default => ''

      t.belongs_to :demo
      t.timestamps
    end

    add_index :goals, :demo_id

    add_column :rules, :goal_id, :integer
  end

  def self.down
    remove_column :rules, :goal_id
    drop_table :goals
  end
end
