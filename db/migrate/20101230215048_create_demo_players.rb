class CreateDemoPlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.string  :name,  :default => "", :null => false
      t.string  :email, :default => "", :null => false
      t.boolean :invited, :default => false
      t.belongs_to :demo
      t.timestamps
    end

    add_index :players, :demo_id
  end

  def self.down
    drop_table :players
  end
end
