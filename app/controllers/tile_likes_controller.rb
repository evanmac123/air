class TileLikesController < ClientAdminBaseController
  skip_before_filter :authorize

  def create
    @tile = Tile.find(params[:tile_id])
    unless @tile.user_tile_likes.find_by_user_id(current_user.id)
      @tile.user_tile_likes.create(user_id: current_user.id)
      schedule_like_ping(@tile)
      respond_to do |format|
        format.js {}
      end
    end
  end

  def destroy
    tile_like = UserTileLike.where(tile_id: params[:tile_id], user_id: current_user.id).first

    if tile_like.present?
      @tile = tile_like.tile
      tile_like.destroy
      schedule_unlike_ping(@tile)
      respond_to do |format|
        format.js {}
      end
    else
      render nothing: true
    end
  end
  
  protected

  def schedule_like_ping(tile)
    case param_path
    when :via_explore_page_thumbnail
      TrackEvent.ping_action('Explore page - Thumbnail', 'Clicked Like', current_user, tile_id: tile.id)
    when :via_explore_page_tile_view
      TrackEvent.ping_action('Explore page - Large Tile View', 'Clicked Like', current_user, tile_id: tile.id)
    end
  end
  def schedule_unlike_ping(tile)
    case param_path
    when :via_explore_page_thumbnail
      TrackEvent.ping_action('Explore page - Thumbnail', 'Clicked Like', current_user, tile_id: tile.id)
    when :via_explore_page_tile_view
      TrackEvent.ping_action('Explore page - Large Tile View', 'Clicked Like', current_user, tile_id: tile.id)
    end
  end
end
