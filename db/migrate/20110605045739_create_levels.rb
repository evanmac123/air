class CreateLevels < ActiveRecord::Migration
  def self.up
    create_table :levels do |t|
      t.string :name, :null => false, :default => ''
      t.integer :threshold, :null => false
      t.belongs_to :demo
      t.timestamps
    end

    add_index :levels, :threshold
    add_index :levels, :demo_id
  end

  def self.down
    drop_table :levels
  end
end
