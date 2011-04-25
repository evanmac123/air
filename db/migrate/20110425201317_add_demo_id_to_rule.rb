class AddDemoIdToRule < ActiveRecord::Migration
  def self.up
    add_column :rules, :demo_id, :integer
    add_index :rules, :demo_id
  end

  def self.down
    remove_index :rules, :column => :demo_id
    remove_column :rules, :demo_id
  end
end
