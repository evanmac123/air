module TileBuilderHelper
  DEFAULT_TILE_IMAGE_PROVIDER = "pixabay".freeze

  def tile_builder_url(tile)
    if tile.user_submitted?
      suggested_tiles_path
    else
      url_for([:client_admin, @tile])
    end
  end
end
