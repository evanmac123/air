class AddIndexToActDemoId < ActiveRecord::Migration
  def self.up
    add_index :acts, :demo_id
  end

  def self.down
    remove_index :acts, :column => :demo_id
  end
end
