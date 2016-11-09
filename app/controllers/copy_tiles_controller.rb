class CopyTilesController < ClientAdminBaseController
  skip_before_filter :authorize
  prepend_before_filter :authorize_by_explore_token

  include LoginByExploreToken

  def create
    tile = Tile.copyable.where(id: params[:tile_id]).first
    copy = tile.copy_to_new_demo(current_user.demo, current_user)
    schedule_tile_creation_ping(copy)
    store_copy_in_redis(params[:tile_id])
    render json: {
      success: true,
      editTilePath: edit_client_admin_tile_path(copy),
      copyCount: tile.reload.copy_count,
      tile_id: tile.id
    }
  end

  private
    def schedule_tile_creation_ping(tile)
      ping('Tile - New', {tile_source: "Explore Page", is_public: tile.is_public, is_copyable: tile.is_copyable, tag: tile.tile_tags.first.try(:title)}, current_user)
    end

    def store_copy_in_redis(tile_id)
      $redis.sadd("boards:#{current_user.demo_id}:copies", tile_id)
    end
end
