class RemoveNameFromTile < ActiveRecord::Migration
  def up
    remove_columns :tiles, :name
  end

  def down
    add_column :tiles, :name, :string, :null => false, :default => ''
  end
end
