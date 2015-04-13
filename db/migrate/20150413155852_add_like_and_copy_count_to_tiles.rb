class Tile < ActiveRecord::Base
end

class AddLikeAndCopyCountToTiles < ActiveRecord::Migration
  def up
    add_column :tiles, :user_tile_copies_count, :integer, default: 0
    add_column :tiles, :user_tile_likes_count, :integer, default: 0

    tile_ids = Tile.pluck(:id)
    tile_ids.each do |tile_id|
      Tile.reset_counters(tile_id, :user_tile_likes, :user_tile_copies)
    end
  end

  def down
    remove_column :tiles, :user_tile_copies_count
    remove_column :tiles, :user_tile_likes_count
  end
end
