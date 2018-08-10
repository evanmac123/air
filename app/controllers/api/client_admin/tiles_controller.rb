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

  private
    def tile_params
      params.require(:tile).permit(:new_status)
    end
end
