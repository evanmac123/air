class TilePreviewsController < ClientAdminBaseController
  def show
    @tile = Tile.viewable_in_public.where(id: params[:id]).first
    @tag = TileTag.where(id: params[:tag]).first
    schedule_mixpanel_pings @tile
  end

  protected

  def schedule_mixpanel_pings(tile)
    ping "Tile - Viewed in Explore", {tile_id: tile.id}, current_user

    if params[:thumb_click_source]
      ping_action_after_dash params[:thumb_click_source], {tile_id: tile.id}, current_user
    end
  end
end
