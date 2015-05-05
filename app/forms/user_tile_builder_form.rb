class UserTileBuilderForm < TileBuilderForm
  def create_url
    suggested_tiles_path
  end

  def update_url
    suggested_tile_path tile
  end

  def newly_built_tile_status
    Tile::USER_DRAFT  
  end
end
