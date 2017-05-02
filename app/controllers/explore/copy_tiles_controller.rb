class Explore::CopyTilesController < ClientAdminBaseController
  include ClientAdmin::TilesPingsHelper
  include ExploreConcern

  def create
    tile = Tile.explore.where(id: params[:tile_id]).first
    tile.copy_to_new_demo(current_user.demo, current_user)
    track_user_channels(tile.channel_list)
    store_copy_in_redis(params[:tile_id])

    render json: {
      success: true,
      tile_id: tile.id
    }
  end

  private

    def store_copy_in_redis(tile_id)
      current_user.rdb[:copies].sadd(tile_id)
    end
end
