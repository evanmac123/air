class CreateTilesDigestTiles < ActiveRecord::Migration
  def change
    create_table :tiles_digest_tiles do |t|
      t.references :tile
      t.references :tiles_digest

      t.timestamps
    end
    add_index :tiles_digest_tiles, :tile_id
    add_index :tiles_digest_tiles, :tiles_digest_id
  end
end
