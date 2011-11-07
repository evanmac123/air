class AddIndexToActsText < ActiveRecord::Migration
  def self.up
    add_index :acts, :text
  end

  def self.down
    remove_index :acts, :column => :text
  end
end
