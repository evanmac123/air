class AddPolyToTile < ActiveRecord::Migration
  def up
    add_column :tiles, :poly, :boolean, null: false, default: false
  end

  def down
    remove_columns :tiles, :poly
  end
end
