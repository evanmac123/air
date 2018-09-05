# frozen_string_literal: true

class Api::ClientAdmin::TilesController < Api::ClientAdminBaseController
  def index
    if (params[:status])
      tiles = Tile.fetch_edit_scoped(
        status: params[:status],
        page: params[:page],
        filter: params[:filter],
        board: current_board
      )
      result = sanitized(tiles, 16)
      render json: result
    else
      render json: Tile.fetch_edit_flow(current_board)
    end
  end

  def update
    tile = current_board.tiles.find(params[:id])
    Tile::StatusUpdater.call(tile: tile, new_status: tile_params[:new_status])
    render json: tile
  end

  def copy_tile
    tile = Tile.find(params[:id])
    copied_tile = TileDuplicateJob.perform_now(tile: tile, demo: current_user.demo, user: current_user)
    result = sanitized([copied_tile], 1)
    render json: result
  end

  def destroy_tile
    tile = Tile.find(params[:id])
    tile.destroy
    render json: { tile_removed: params[:id] }
  end

  private
    def tile_params
      params.require(:tile).permit(:new_status)
    end

    def sanitized(tiles, amount)
      Tile.react_sanitize(tiles, amount) do |tile|
        {
          "tileShowPath" => "/client_admin/tiles/#{tile.id}",
          "editPath" => "/client_admin/tiles/#{tile.id}/edit",
          "headline" => tile.headline,
          "id" => tile.id,
          "thumbnail" => tile.thumbnail_url,
          "planDate" => tile.plan_date,
          "activeDate" => tile.activated_at,
          "archiveDate" => tile.archived_at,
          "fullyAssembled" => tile.is_fully_assembled?,
          "campaignColor" => tile.campaign_color,
          "unique_views" => tile.unique_viewings_count,
          "views" => tile.total_viewings_count,
          "completions" => tile.user_tile_likes_count,
        }
      end
    end
end
