class TileLikesController < ClientAdminBaseController
  skip_before_filter :authorize
  prepend_before_filter :authorize_by_explore_token

  include LoginByExploreToken

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
      TrackEvent.ping_action('Explore page - Interaction', 'Clicked Vote Up', current_user, {tile_id: tile.id, page: "Tile thumbnail"})
    when :via_explore_page_tile_view
      TrackEvent.ping_action('Explore page - Interaction', 'Clicked Vote Up', current_user, {tile_id: tile.id, page: "Large Tile View"})
    when :via_explore_page_subject_tag
      TrackEvent.ping_action('Explore page - Interaction', 'Clicked Vote Up', current_user, {tile_id: tile.id, page: "Tile Subject Tag"})
    end
  end

  def schedule_unlike_ping(tile)
    schedule_like_ping(tile)
  end
end
