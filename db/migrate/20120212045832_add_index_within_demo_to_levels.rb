class AddIndexWithinDemoToLevels < ActiveRecord::Migration
  def self.up
    add_column :levels, :index_within_demo, :integer
  end

  def self.down
    remove_column :levels, :index_within_demo
  end
end
