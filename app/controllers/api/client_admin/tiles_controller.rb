# frozen_string_literal: true

class Api::ClientAdmin::TilesController < Api::ClientAdminBaseController
  def index
    render json: Tile.fetch_edit_flow(current_board)
  end

  def update
    tile = current_board.tiles.find(params[:id])
    Tile::StatusUpdater.call(tile: tile, new_status: tile_params[:new_status])
    render json: tile
  end

  def copy_tile
    tile = Tile.find(params[:id])
    copied_tile = TileDuplicateJob.perform_now(tile: tile, demo: current_user.demo, user: current_user)
    result = Tile.react_sanitize([copied_tile], 1) do |tile|
      {
        "tileShowPath" => "/client_admin/tiles/#{tile.id}",
        "editPath" => "/client_admin/tiles/#{tile.id}/edit",
        "headline" => tile.headline,
        "id" => tile.id,
        "thumbnail" => tile.thumbnail_url,
        "planDate" => tile.plan_date,
        "activeDate" => tile.activated_at,
        "archiveDate" => tile.archived_at,
        "fullyAssembled" => tile.is_fully_assembled?
      }
    end
    render json: result
  end

  private
    def tile_params
      params.require(:tile).permit(:new_status)
    end
end
