module TileBuilderHelper
  def tile_image_providers
    ENV['IMAGE_PROVIDERS'].split(",").to_json
  end

  def tile_builder_url(tile)
    if tile.user_submitted?
      suggested_tiles_path
    else
      url_for([:client_admin, @tile])
    end
  end
end
