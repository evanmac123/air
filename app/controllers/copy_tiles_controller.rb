class CopyTilesController < ClientAdminBaseController
  skip_before_filter :authorize

  def create
    tile = Tile.copyable.where(id: params[:tile_id]).first
    copy = tile.copy_to_new_demo(current_user.demo, current_user)
    schedule_copy_ping(tile)
    render json: {
      success: true, 
      editTilePath: edit_client_admin_tile_path(copy),
      copyCount: tile.copy_count
    }
  end

  protected
  
  def schedule_copy_ping(tile)
    case param_path
    when :via_explore_page_thumbnail
      TrackEvent.ping_action('Explore page - Interaction', 'Clicked Copy', current_user, {tile_id: tile.id, page: "Tile thumbnail"})
    when :via_explore_page_tile_view
      TrackEvent.ping_action('Explore page - Interaction', 'Clicked Copy', current_user, {tile_id: tile.id, page: "Large Tile View"})            
    end
  end
  
end
