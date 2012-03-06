class AddHiddenToActs < ActiveRecord::Migration
  def self.up
    add_column :acts, :hidden, :boolean
    execute "UPDATE acts SET hidden=false WHERE text != ''"
    execute "UPDATE acts SET hidden=true WHERE text = ''"
    change_column :acts, :hidden, :boolean, :default => false, :null => false
    add_index :acts, :hidden
  end

  def self.down
    remove_column :acts, :hidden
  end
end
