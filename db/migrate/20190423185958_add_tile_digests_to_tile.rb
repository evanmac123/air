class AddTileDigestsToTile < ActiveRecord::Migration
  def change
    add_reference :tiles, :tile_digest, index: true, foreign_key: true
  end
end
