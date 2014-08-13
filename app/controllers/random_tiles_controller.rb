class RandomTilesController < ClientAdminBaseController
  include LoginByExploreToken

  def show
    tile = RandomPublicTileChooser.new.choose_tile
    schedule_ping
    redirect_to explore_tile_preview_path(tile)
  end

  protected

  def schedule_ping
    TrackEvent.ping_action('Explore page - Interaction', 'Clicked Random Tile', current_user)
  end
end
