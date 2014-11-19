class AddTileCompletionCounterCacheToTiles < ActiveRecord::Migration
  def self.up
    add_column :tiles, :tile_completions_count, :integer, default: 0

    if const_defined?("Tile")
      Tile.find_each do |tile|
        Tile.reset_counters(tile.id, :tile_completions)
      end
    end
  end

  def self.down
    remove_column :tiles, :tile_completions_count
  end
end
