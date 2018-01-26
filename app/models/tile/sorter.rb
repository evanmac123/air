# frozen_string_literal: true

class Tile::Sorter
  def self.call(tile:, sort_params:)
    InsertTileBetweenTiles.new(
      tile,
      sort_params[:left_tile_id],
      sort_params[:right_tile_id],
      sort_params[:status],
      sort_params[:redigest]
    ).insert!
  end
end
