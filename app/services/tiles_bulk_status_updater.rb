# frozen_string_literal: true

class TilesBulkStatusUpdater
  def self.call(demo:, tiles:, status:)
    max_tile_position = demo.tiles.active.maximum(:position).to_i

    tiles.order(position: :asc).each do |tile|
      max_tile_position += 1
      tile.assign_attributes(status: status, position: max_tile_position)
      tile.save
    end
  end
end
