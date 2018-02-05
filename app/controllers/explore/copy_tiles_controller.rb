# frozen_string_literal: true

class Explore::CopyTilesController < ClientAdminBaseController
  include ClientAdmin::TilesPingsHelper
  include ExploreConcern

  def create
    tile = explore_tile || organization_tile
    return render_json_access_denied unless tile

    TileCopyJob.perform_later(tile: tile, demo: current_user.demo, user: current_user)
    store_copy_in_redis(params[:tile_id])

    render json: {
      success: true,
      tile_id: tile.id
    }
  end

  private

    def explore_tile
      Tile.explore.where(id: params[:tile_id]).first
    end

    def organization_tile
      current_user.organization.tiles.active.where(id: params[:tile_id]).first
    end

    def store_copy_in_redis(tile_id)
      current_user.rdb[:copies].sadd(tile_id)
    end
end
