# frozen_string_literal: true

class Api::ClientAdmin::Tile::SortsController < Api::ClientAdminBaseController
  def create
    @tile = demo_tiles.find_by(id: params[:tile_id])

    update_tile_status
    sort_tile

    render json: {
      tileId: @tile.id,
      tileHTML: tile_html,
      meta: {
        tileCounts: demo_tiles.group(:status).count
      }
    }
  end

  private

    def update_tile_status
      if new_status.present?
        Tile::StatusUpdater.call(tile: @tile, new_status: new_status)
      end
    end

    def sort_tile
      Tile::Sorter.call(tile: @tile, left_tile_id: sort_params[:left_tile_id])
    end

    def new_status
      sort_params[:new_status]
    end

    def demo_tiles
      demo.tiles
    end

    def demo
      current_user.demo
    end

    def sort_params
      params.require(:sort).permit(:left_tile_id, :new_status)
    end

    def tile_presenter(tile)
      present(tile, SingleAdminTilePresenter, is_ie: browser.ie?)
    end

    def tile_html
      render_to_string(
        formats: [:html],
        partial: "client_admin/tiles/manage_tiles/single_tile",
        locals: { presenter:  tile_presenter(@tile) }
      )
    end
end
