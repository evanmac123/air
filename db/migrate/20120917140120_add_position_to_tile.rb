class AddPositionToTile < ActiveRecord::Migration
  def up 
    add_column :tiles, :position, :integer
  end

  def down
    remove_columns :tiles, :position
  end
end
