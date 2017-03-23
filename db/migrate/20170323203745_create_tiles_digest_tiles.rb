class CreateTilesDigestTiles < ActiveRecord::Migration
  def change
    create_table :tiles_digest_tiles do |t|
      t.references :tiles_digest
      t.references :tile

      t.timestamps
    end
    add_index :tiles_digest_tiles, :tiles_digest_id
    add_index :tiles_digest_tiles, :tile_id
  end
end
