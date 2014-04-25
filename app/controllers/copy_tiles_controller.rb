class CopyTilesController < ClientAdminBaseController
  skip_before_filter :authorize

  def create
    tile = Tile.copyable.where(id: params[:tile_id]).first
    copy = tile.copy_to_new_demo(current_user.demo, current_user)
    schedule_copy_ping(tile)
    tile.user_tile_copies.create!(user_id: current_user.id)
    render json: {success: true, editTilePath: edit_client_admin_tile_path(copy)}
  end

  protected
  
  def schedule_copy_ping(tile)
    case param_path
    when :via_explore_page_thumbnail
      TrackEvent.ping_action('Explore page - Thumbnail', 'Clicked Copy', current_user)
    when :via_explore_page_tile_view
      TrackEvent.ping_action('Explore page - Large Tile View', 'Clicked Copy', current_user)            
    end
  end
  
end
