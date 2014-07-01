class RandomTilesController < ClientAdminBaseController
  def show
    tile = RandomPublicTileChooser.new.choose_tile
    redirect_to explore_tile_preview_path(tile)
  end
end
