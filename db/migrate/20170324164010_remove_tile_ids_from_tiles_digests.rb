class RemoveTileIdsFromTilesDigests < ActiveRecord::Migration
  def up
    remove_column :tiles_digests, :tile_ids
  end

  def down
    add_column :tiles_digests, :tile_ids, :text
  end
end
