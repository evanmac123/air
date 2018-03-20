# frozen_string_literal: true

class TilesBulkActivator
  def self.call(demo:, tiles:)
    max_tile_position = demo.tiles.active.maximum(:position).to_i

    tiles.order(position: :asc).each do |tile|
      max_tile_position += 1
      tile.position = max_tile_position
      Tile::StatusUpdater.call(tile: tile, new_status: Tile::ACTIVE)
    end
  end
end
