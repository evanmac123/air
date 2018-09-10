# frozen_string_literal: true

class Api::ClientAdmin::TilesController < Api::ClientAdminBaseController
  include Tile::ReactProcessing
  def index
    tiles = if (params[:status])
      scoped_tiles = Tile.fetch_edit_scoped(
        status: params[:status],
        page: params[:page] || 1,
        filter: params[:filter] || "",
        board: current_board
      )
      Tile::ReactProcessing.sanitize_for_edit_flow(scoped_tiles, 16)
    else
      Tile.fetch_edit_flow(current_board)
    end
    render json: tiles
  end

  def show
    tile = Tile.from_board_with_campaigns(current_board).find(params[:id])
    result = Tile::ReactProcessing.sanitize_for_edit_flow([tile], 1)
    render json: result.first
  end

  def update
    tile = current_board.tiles.find(params[:id])
    Tile::StatusUpdater.call(tile: tile, new_status: tile_params[:newStatus])
    Tile::Sorter.call(tile: tile, left_tile_id: nil)
    render json: tile
  end

  def copy_tile
    tile = Tile.find(params[:id])
    copied_tile = TileDuplicateJob.perform_now(tile: tile, demo: current_user.demo, user: current_user)
    result = Tile::ReactProcessing.sanitize_for_edit_flow([copied_tile], 1)
    render json: result
  end

  def destroy_tile
    tile = Tile.find(params[:id])
    tile.destroy
    render json: { tile_removed: params[:id] }
  end

  private
    def tile_params
      params.require(:tile).permit(:newStatus)
    end
end
