class AddUniqueToTileIdOnRecommendedTile < ActiveRecord::Migration
  def change
    add_index :recommended_tiles, :tile_id, :unique => true
  end
end
