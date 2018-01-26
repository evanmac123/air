class Tile::Sorter
  def self.call(tile:, sort_params:)
    Tile.insert_tile_between(
      tile.id,
      sort_params[:left_tile_id],
      sort_params[:right_tile_id],
      sort_params[:status],
      sort_params[:redigest]
    )
  end
end
