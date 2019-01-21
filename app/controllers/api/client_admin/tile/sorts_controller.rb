# frozen_string_literal: true

class Api::ClientAdmin::Tile::SortsController < Api::ClientAdminBaseController
  def create
    @tile = current_user.demo.tiles.find(params[:tile_id])

    update_tile_status
    sort_tile

    render json: {
      tileId: @tile.id,
    }
  end

  private
    def update_tile_status
      if sort_params[:new_status].present?
        Tile::StatusUpdater.call(tile: @tile, new_status: sort_params[:new_status])
      end
    end

    def sort_tile
      Tile::Sorter.call(tile: @tile, left_tile_id: sort_params[:left_tile_id])
    end

    def sort_params
      params.require(:sort).permit(:left_tile_id, :new_status)
    end
end
