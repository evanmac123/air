class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :name, :null => false, :default => ""
      t.belongs_to :demo
      t.timestamps
    end

    add_index :locations, :demo_id
  end

  def self.down
    drop_table :locations
  end
end
