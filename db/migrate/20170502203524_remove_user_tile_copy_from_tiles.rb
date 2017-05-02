class RemoveUserTileCopyFromTiles < ActiveRecord::Migration
  def up
    remove_column :tiles, :user_tile_copies_count
  end

  def down
  end
end
