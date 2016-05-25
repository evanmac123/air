class CopyTilesController < ClientAdminBaseController
  skip_before_filter :authorize
  prepend_before_filter :authorize_by_explore_token

  include LoginByExploreToken

  def create
    tile = Tile.copyable.where(id: params[:tile_id]).first
    copy = tile.copy_to_new_demo(current_user.demo, current_user)
    schedule_copy_ping(tile)
    schedule_tile_creation_ping(copy)
    render json: {
      success: true,
      editTilePath: edit_client_admin_tile_path(copy),
      copyCount: tile.reload.copy_count
    }
  end

  protected
    def schedule_copy_ping(tile)
      case param_path
      when "via_explore_page_thumbnail"
        TrackEvent.ping_action('Explore page - Interaction', 'Clicked Copy', current_user, {tile_id: tile.id, page: "Tile thumbnail"})
      when "via_explore_page_tile_view"
        TrackEvent.ping_action('Explore page - Interaction', 'Clicked Copy', current_user, {tile_id: tile.id, page: "Large Tile View"})
      when "via_explore_page_subject_tag"
        TrackEvent.ping_action('Explore page - Interaction', 'Clicked Copy', current_user, {tile_id: tile.id, page: "Tile Subject Tag"})
      end
    end

    def schedule_tile_creation_ping(tile)
      ping('Tile - New', {tile_source: "Explore Page", is_public: tile.is_public, is_copyable: tile.is_copyable, tag: tile.tile_tags.first.try(:title)}, current_user)
    end
end
