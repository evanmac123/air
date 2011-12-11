class AddPrequisitesJoinTable < ActiveRecord::Migration
  def self.up
    create_table :prerequisites, :id => false do |t|
      t.integer :prerequisite_id, :null => false
      t.integer :suggested_task_id, :null => false
    end

    add_index :prerequisites, :prerequisite_id
    add_index :prerequisites, :suggested_task_id
  end

  def self.down
    drop_table :prerequisites
  end
end
