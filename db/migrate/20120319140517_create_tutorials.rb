class CreateTutorials < ActiveRecord::Migration
  def self.up
    create_table :tutorials do |t|
      t.integer :user_id, :null => false
      t.datetime :ended_at
      t.boolean :completed, :null => false, :default => false
      t.integer :current_step, :null => false, :default => 0
      t.integer :friend_id
      t.text :first_act, :null => false, :default => ''
      t.timestamps
    end
  end

  def self.down
    drop_table :tutorials
  end
end
