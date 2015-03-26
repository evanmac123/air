class CorrectPublicTiles < ActiveRecord::Migration
  def up
    Tile.includes(:tile_taggings).includes(:tile_tags).each do |tile|
      if tile.is_public? && 
        tile.tile_taggings.size < 1 && 
        tile.tile_tags.size < 1

        tile.update_attribute(:is_public, false)
      end
    end
  end

  def down
  end
end
