class TilePreviewsController < ClientAdminBaseController
  def show
    @tile = Tile.viewable_in_public.where(id: params[:id]).first
    schedule_mixpanel_ping @tile
  end

  protected

  def schedule_mixpanel_ping(tile)
    ping "Tile - Viewed in Explore", {tile_id: tile.id}, current_user
  end
end
