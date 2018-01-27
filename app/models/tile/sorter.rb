# frozen_string_literal: true

class Tile::Sorter
  def self.call(tile:, params:)
    if params[:new_status].present?
      Tile::StatusUpdater.call(tile: tile, new_status: params[:new_status], redigest: params[:redigest])
    end

    InsertTileBetweenTiles.new(tile, params[:left_tile_id]).insert!
  end
end
