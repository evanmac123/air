class Explore::CopyTilesController < ClientAdminBaseController
  include ClientAdmin::TilesPingsHelper

  def create
    tile = Tile.explore.where(id: params[:tile_id]).first
    copy = tile.copy_to_new_demo(current_user.demo, current_user)
    schedule_tile_creation_ping(copy, "Explore Page")
    tag_user_with_channels(tile.channel_list)
    store_copy_in_redis(params[:tile_id])
    render json: {
      success: true,
      editTilePath: edit_client_admin_tile_path(copy),
      copyCount: tile.reload.copy_count,
      tile_id: tile.id
    }
  end

  private

    def store_copy_in_redis(tile_id)
      current_user.rdb[:copies].sadd(tile_id)
    end

    def tag_user_with_channels(channel_list)
      current_user.channel_list.add(channel_list)
      current_user.save
    end
end
